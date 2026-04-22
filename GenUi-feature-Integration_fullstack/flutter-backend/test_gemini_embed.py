import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("GOOGLE_API_KEY")

genai.configure(api_key=api_key)
print("Available Embedding Models:")
try:
    models = [m.name for m in genai.list_models() if 'embedContent' in m.supported_generation_methods]
    for m in models:
        print(f"- {m}")
except Exception as e:
    print(f"Error: {e}")
