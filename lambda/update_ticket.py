import boto3
import json
from datetime import datetime

# DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('SenatSupport-Tickets')


def lambda_handler(event, context):

    # Get ticket ID from path
    ticket_id = event["pathParameters"]["id"]

    # Parse body
    body = json.loads(event["body"])

    # New status
    new_status = body.get("status")

    # Engineer updating ticket
    resolved_by = body.get("resolved_by", "")

    # Current timestamp
    updated_at = datetime.utcnow().isoformat()

    # Build update expression
    update_expression = """
    SET #s = :status,
        UpdatedAt = :updated_at
    """

    expression_values = {
        ":status": new_status,
        ":updated_at": updated_at
    }

    expression_names = {
        "#s": "Status"
    }

    # Add resolved info if resolved
    if new_status == "resolved":

        update_expression += """
        , ResolvedBy = :resolved_by,
          ResolvedAt = :resolved_at
        """

        expression_values[":resolved_by"] = resolved_by
        expression_values[":resolved_at"] = updated_at

    # Add closed timestamp if closed
    if new_status == "closed":

        update_expression += """
        , ClosedAt = :closed_at
        """

        expression_values[":closed_at"] = updated_at

    # Update ticket
    table.update_item(
        Key={
            "TicketID": ticket_id
        },
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_values,
        ExpressionAttributeNames=expression_names
    )

    # Response
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Ticket updated successfully",
            "ticket_id": ticket_id,
            "new_status": new_status,
            "updated_at": updated_at
        })
    }