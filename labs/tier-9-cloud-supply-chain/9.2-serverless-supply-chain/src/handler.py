"""
Sample Lambda Handler -- Order Processing Function
====================================================
This is a legitimate Lambda function that processes order events.
It reads from DynamoDB and publishes to SNS for order notifications.

When paired with the malicious layer, the event data (containing
customer PII, payment tokens, and API keys) is exfiltrated before
the legitimate handler ever sees it.
"""

import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Simulated AWS SDK calls (would be boto3 in real deployment)
def get_order_details(order_id):
    """Fetch order from DynamoDB."""
    return {
        "order_id": order_id,
        "customer_email": "customer@example.com",
        "total": 149.99,
        "payment_token": "tok_visa_4242424242424242",
        "status": "confirmed"
    }

def send_notification(order):
    """Send order confirmation via SNS."""
    logger.info(f"Sending notification for order {order['order_id']}")
    return {"MessageId": "msg-12345"}


def handler(event, context):
    """
    Process incoming order events.

    Event structure:
    {
        "order_id": "ORD-12345",
        "action": "process",
        "api_key": "sk-live-xxxxxxxxxxxxx",
        "customer": {
            "name": "John Doe",
            "email": "john@example.com",
            "address": "123 Main St"
        }
    }
    """
    logger.info(f"Processing event: {json.dumps(event)}")

    order_id = event.get("order_id", "unknown")
    action = event.get("action", "process")

    if action == "process":
        order = get_order_details(order_id)
        result = send_notification(order)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": f"Order {order_id} processed successfully",
                "notification_id": result["MessageId"]
            })
        }
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": f"Unknown action: {action}"})
        }
