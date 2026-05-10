import boto3
import uuid
import json

# AWS services
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('SenatSupport-Tickets')

sns = boto3.client('sns')

TOPIC_ARN = "arn:aws:sns:us-east-1:490848272326:SenatSupport-Alerts"

# Simple AI logic
def analyze_with_ai(text):

    text = text.lower()

    if "fire" in text or "smoke" in text:
        return {
            "category": "hardware",
            "urgency": 10
        }

    elif "slow" in text or "internet" in text:
        return {
            "category": "network",
            "urgency": 5
        }

    elif "error" in text or "fail" in text:
        return {
            "category": "software",
            "urgency": 7
        }

    else:
        return {
            "category": "general",
            "urgency": 2
        }


def lambda_handler(event, context):

    # Parse request body
    body = event.get("body")

    if isinstance(body, str):
        body = json.loads(body)

    elif body is None:
        body = {}

    # Get message
    user_query = body.get("message", "No message")

    # Analyze message
    ai_result = analyze_with_ai(user_query)

    # Generate ticket ID
    ticket_id = str(uuid.uuid4())[:8]

    # Save to DynamoDB
    table.put_item(
        Item={
            "TicketID": ticket_id,
            "Issue": user_query,
            "Category": ai_result["category"],
            "Urgency": ai_result["urgency"]
        }
    )

    # 🔥 Send SNS alert if urgency is high
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
"""
        )

    # Return response
    return {
        "statusCode": 200,
        "body": json.dumps({
            "ticket": ticket_id,
            "category": ai_result["category"],
            "urgency": ai_result["urgency"]
        })
    }