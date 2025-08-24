import json
from datetime import datetime, timezone
import os


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def resp(status, body: dict):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def env(name: str, default: str = ""):
    return os.getenv(name, default)
