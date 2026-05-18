import json
from dotenv import load_dotenv
import os

load_dotenv()

json_str = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
path_str = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")

print("FIREBASE_SERVICE_ACCOUNT_PATH:", path_str)
if json_str:
    print("FIREBASE_SERVICE_ACCOUNT_JSON found (length):", len(json_str))
    try:
        parsed = json.loads(json_str)
        print("Successfully parsed JSON! Project ID:", parsed.get("project_id"))
    except Exception as e:
        print("Failed to parse JSON string:", e)
else:
    print("FIREBASE_SERVICE_ACCOUNT_JSON NOT found in env!")
