import json
from datetime import datetime, timezone

# IMPORTANT: In Lambda, do NOT use relative imports (e.g., from .dynamo ...).
# Keep dynamo.py in the same folder and import it plainly:
from dynamo import put_item, get_item, query_by_name


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def resp(status: int, body: dict, headers: dict | None = None):
    base = {"Content-Type": "application/json"}
    if headers:
        base.update(headers)
    return {
        "statusCode": status,
        "headers": base,
        "body": json.dumps(body, default=str),
        "isBase64Encoded": False,
    }


def _parse_body(event) -> dict:
    body = event.get("body")
    if body is None:
        return {}
    if isinstance(body, (dict, list)):
        return body
    try:
        return json.loads(body) if body else {}
    except json.JSONDecodeError:
        return {}


def handler(event, context):
    """
    Supports:
      POST /clients      body: {"ClientID": "...", "ClientName": "...", ...}
      GET  /clients?ClientID=123
      GET  /clients?ClientName=Acme
      GET  /health
    """
    method = (event.get("httpMethod") or "GET").upper()
    path = event.get("path") or "/"
    query = event.get("queryStringParameters") or {}

    # Simple health check
    if path.endswith("/health"):
        return resp(200, {"status": "ok", "time": now_iso()})

    if path.endswith("/clients"):
        if method == "POST":
            data = _parse_body(event)
            cid = data.get("ClientID")
            cname = data.get("ClientName")

            if not cid or not cname:
                return resp(400, {"error": "ClientID and ClientName are required"})

            # add server-side timestamp
            data.setdefault("CreatedAt", now_iso())

            try:
                put_item(data)
                return resp(201, {"message": "created", "item": data})
            except Exception as e:
                # bubble a clean 500 for API Gateway
                return resp(500, {"error": f"write_failed: {e}"})

        elif method == "GET":
            cid = query.get("ClientID")
            cname = query.get("ClientName")

            try:
                if cid:
                    item = get_item(cid)
                    return resp(200, {"item": item})
                if cname:
                    items = query_by_name(cname)
                    return resp(200, {"items": items})
                return resp(400, {"error": "provide ClientID or ClientName"})
            except Exception as e:
                return resp(500, {"error": f"read_failed: {e}"})

    return resp(404, {"error": "not_found"})
