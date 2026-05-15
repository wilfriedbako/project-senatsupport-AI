import boto3
import uuid
import json
from datetime import datetime

# AWS services
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('SenatSupport-Tickets')

sns = boto3.client('sns')

bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-east-1'
)

TOPIC_ARN = "arn:aws:sns:us-east-1:490848272326:SenatSupport-Alerts"


# AI ticket analysis using Amazon Bedrock
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

    try:

        response = bedrock.invoke_model(
            modelId="amazon.nova-lite-v1:0",
            body=json.dumps({
                "messages": [
                    {
                        "role": "user",
                        "content": [
                            {
                                "text": prompt
                            }
                        ]
                    }
                ],
                "inferenceConfig": {
                    "maxTokens": 200,
                    "temperature": 0.2
                }
            })
        )

        response_body = json.loads(response["body"].read())

        output_text = response_body["output"]["message"]["content"][0]["text"]

        # Extract JSON only
        start = output_text.find("{")
        end = output_text.rfind("}") + 1

        clean_json = output_text[start:end]

        return json.loads(clean_json)

    except Exception as e:

        return {
            "category": "general",
            "urgency": 3,
            "summary": f"AI processing failed: {str(e)}"
        }


# Engineer assignment logic
def assign_engineer(category, urgency):

    # High urgency goes directly to senior engineer
    if urgency >= 8:
        return "Wilfried"

    elif category == "hardware":
        return "Kya"

    elif category == "network":
        return "Enzo"

    elif category == "software":
        return "Hakim"

    else:
        return "Bako"


def lambda_handler(event, context):

    # Parse request body
    body = event.get("body")

    if isinstance(body, str):
        body = json.loads(body)

    elif body is None:
        body = {}

    # Get user message
    user_query = body.get("message", "No message")

    # Analyze with AI
    ai_result = analyze_with_ai(user_query)

    # Assign engineer automatically
    assigned_engineer = assign_engineer(
        ai_result["category"],
        ai_result["urgency"]
    )

    # Generate ticket ID
    ticket_id = str(uuid.uuid4())[:8]

    # Timestamp
    created_at = datetime.utcnow().isoformat()
    
# Save ticket to DynamoDB
table.put_item(
    Item={
        "TicketID": ticket_id,
        "Issue": user_query,
        "Category": ai_result["category"],
        "Urgency": ai_result["urgency"],
        "Summary": ai_result["summary"],
        "AssignedTo": assigned_engineer,
        "Status": "open",
        "CreatedAt": created_at,
        "ResolvedBy": "",
        "ResolvedAt": "",
        "ClosedAt": "",
        "UpdatedAt": created_at
    }
)

    # Send SNS alert for urgent tickets
    if ai_result["urgency"] >= 8:

        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject="High Urgency Support Ticket",
            Message=f"""
New urgent ticket detected

Ticket ID: {ticket_id}

Issue:
{user_query}

Category:
{ai_result['category']}

Urgency:
{ai_result['urgency']}

Summary:
{ai_result['summary']}

Assigned Engineer:
{assigned_engineer}

Status:
open
"""
        )

    # API response
    return {
        "statusCode": 200,
        "body": json.dumps({
            "ticket": ticket_id,
            "category": ai_result["category"],
            "urgency": ai_result["urgency"],
            "summary": ai_result["summary"],
            "assigned_to": assigned_engineer,
            "status": "open",
            "created_at": created_at
        })
    }