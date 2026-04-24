import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("GOOGLE_API_KEY")

if not api_key:
    print("No GOOGLE_API_KEY found in .env")
else:
    genai.configure(api_key=api_key)
    print("Available Models:")
    try:
        models = [m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods]
        for m in models:
            print(f"- {m}")
    except Exception as e:
        print(f"Error listing models: {e}")
