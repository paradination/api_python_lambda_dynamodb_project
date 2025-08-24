import os
import requests
import json

# e.g., https://xxxx.execute-api.us-east-1.amazonaws.com/dev
API_URL = os.getenv("API_URL")
API_KEY = os.getenv("X_API_KEY")


def headers():
    h = {"Content-Type": "application/json"}
    if API_KEY:
        h["x-api-key"] = API_KEY
    return h


def post_client(client_id, name, tier="bronze"):
    url = f"{API_URL}/clients"
    r = requests.post(url, data=json.dumps(
        {"ClientID": client_id, "ClientName": name, "Tier": tier}), headers=headers(), timeout=10)
    print(r.status_code, r.text)


def get_client_by_id(client_id):
    url = f"{API_URL}/clients"
    r = requests.get(
        url, params={"ClientID": client_id}, headers=headers(), timeout=10)
    print(r.status_code, r.text)


if __name__ == "__main__":
    post_client("111211122", "otb", "gold")
    get_client_by_id("111211122")
