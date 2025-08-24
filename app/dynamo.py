import os
import boto3
from botocore.exceptions import ClientError

# Read table name from the Lambda environment variable
TABLE = os.getenv("TABLE_NAME")
if not TABLE:
    raise RuntimeError("TABLE_NAME environment variable not set")

# DynamoDB resource (uses Lambda execution role credentials)
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE)   # <-- correct attribute


def put_item(item: dict) -> None:
    """Insert/overwrite an item."""
    try:
        table.put_item(Item=item)
    except ClientError as e:
        raise RuntimeError(f"DynamoDB put_item failed: {e}")


def get_item(client_id: str):
    """Get a single item by the partition key ClientID."""
    try:
        resp = table.get_item(Key={"ClientID": client_id})
        return resp.get("Item")
    except ClientError as e:
        raise RuntimeError(f"DynamoDB get_item failed: {e}")


def query_by_name(name: str):
    """
    Demo search by ClientName using a table scan.
    NOTE: For production, create a GSI on ClientName and Query instead of Scan.
    """
    try:
        scan = table.scan()
        return [it for it in scan.get("Items", []) if it.get("ClientName") == name]
    except ClientError as e:
        raise RuntimeError(f"DynamoDB query_by_name failed: {e}")
