import boto3
import uuid
import json

# AWS services
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('SenatSupport-Tickets')

sns = boto3.client('sns')

bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-east-1'
)

TOPIC_ARN = "arn:aws:sns:us-east-1:490848272326:SenatSupport-Alerts"


# Real AI analysis using Bedrock
def analyze_with_ai(text):

    prompt = f"""
You are an IT support AI.

Analyze this support ticket:

{text}

Return ONLY valid JSON like this:
{{
  "category": "hardware/software/network/general",
  "urgency": 1-10,
  "summary": "short summary"
}}
"""

    response = bedrock.invoke_model(
        modelId="amazon.titan-text-lite-v1",
        body=json.dumps({
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": 200,
                "temperature": 0.2
            }
        })
    )

    response_body = json.loads(response["body"].read())

    output_text = response_body["results"][0]["outputText"]

    # Clean Bedrock response into valid JSON
    start = output_text.find("{")
    end = output_text.rfind("}") + 1

    clean_json = output_text[start:end]

    return json.loads(clean_json)


def lambda_handler(event, context):

    # Parse request body
    body = event.get("body")

    if isinstance(body, str):
        body = json.loads(body)

    elif body is None:
        body = {}

    # Get message
    user_query = body.get("message", "No message")

    # Analyze message with Bedrock AI
    ai_result = analyze_with_ai(user_query)

    # Generate ticket ID
    ticket_id = str(uuid.uuid4())[:8]

    # Save to DynamoDB
    table.put_item(
        Item={
            "TicketID": ticket_id,
            "Issue": user_query,
            "Category": ai_result["category"],
            "Urgency": ai_result["urgency"],
            "Summary": ai_result["summary"]
        }
    )

    # Send SNS alert if urgency is high
    if ai_result["urgency"] >= 8:

        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject="High Urgency Support Ticket",
            Message=f"""
New urgent ticket detected

Ticket ID: {ticket_id}
Issue: {user_query}
Category: {ai_result['category']}
Urgency: {ai_result['urgency']}
Summary: {ai_result['summary']}
"""
        )

    # Return response
    return {
        "statusCode": 200,
        "body": json.dumps({
            "ticket": ticket_id,
            "category": ai_result["category"],
            "urgency": ai_result["urgency"],
            "summary": ai_result["summary"]
        })
    }