import boto3
import json

dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('SenatSupport-Tickets')


def lambda_handler(event, context):

    response = table.scan()

    items = response.get("Items", [])

    total = len(items)

    resolved = len([
        item for item in items
        if item.get("Status") == "resolved"
    ])

    open_tickets = len([
        item for item in items
        if item.get("Status") == "open"
    ])

    critical = len([
        item for item in items
        if int(item.get("Urgency", 0)) >= 8
    ])

    return {
        "statusCode": 200,
        "body": json.dumps({
            "total": total,
            "resolved": resolved,
            "open": open_tickets,
            "critical": critical
        })
    }