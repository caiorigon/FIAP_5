# main_llamaindex.py
import os
from fastapi import FastAPI, UploadFile, File, Form
from pathlib import Path
from dotenv import load_dotenv

# LlamaIndex Imports
from llama_index.core import SimpleDirectoryReader, VectorStoreIndex, Settings
from llama_index.multi_modal_llms.gemini import GeminiMultiModal
from llama_index.embeddings.gemini import GeminiEmbedding

load_dotenv()
# --- Configure LlamaIndex Settings to use Gemini ---
Settings.llm = GeminiMultiModal(model_name="models/gemini-1.5-pro-latest")
Settings.embed_model = GeminiEmbedding(model_name="models/text-embedding-004")

# --- Setup: This part would run once when your server starts ---
# Create a dummy knowledge base for our rules
Path("knowledge").mkdir(exist_ok=True)
with open("knowledge/rules.md", "w") as f:
    f.write(
        """
# Our Company's Architectural Rules
1. All public-facing APIs must be protected by an API Gateway with rate limiting.
2. Databases must never be exposed to the public internet. They should reside in a private subnet.
3. Use a managed database service (like SQL MI or RDS) instead of running a database on a VM.
"""
    )

# Load data and build the index
documents = SimpleDirectoryReader("./knowledge").load_data()
index = VectorStoreIndex.from_documents(documents)
# --- End of Setup ---


app = FastAPI()

# Note: GOOGLE_API_KEY environment variable is used automatically
gemini_llm = GeminiMultiModal(model_name="models/gemini-1.5-pro-latest")

# If you wish to use OpenAI use this model
# openai_llm = OpenAIMultiModal(model="gpt-4o", max_new_tokens=1500)


@app.post("/analyse-diagram")
async def analyse_diagram(prompt: str = Form(...), image_file: UploadFile = File(...)):
    """
    Receives a diagram and a prompt, uses RAG to find failures
    based on our internal knowledge base.
    """
    try:
        # Save the uploaded image temporarily
        image_path = f"./{image_file.filename}"
        with open(image_path, "wb") as f:
            f.write(await image_file.read())

        # The core of LlamaIndex RAG: create a query engine
        query_engine = index.as_query_engine(llm=gemini_llm)
        # For OpenAI use this code
        # query_engine = index.as_query_engine(llm=openai_llm)

        # Query with both the image and text. LlamaIndex handles the rest.
        response = query_engine.query(
            f"{prompt}. Use the context provided to find specific rule violations."
        )

        # Clean up the temp image
        os.remove(image_path)

        return {"response": str(response)}

    except Exception as e:
        return {"error": str(e)}


# To run this:
# 1. pip install "llama-index[multi_modal_llms-gemini,embeddings-gemini]" fastapi uvicorn python-dotenv python-multipart
# 2. Set your GOOGLE_API_KEY environment variable.
# 3. Run the server: uvicorn llamaIndex:app --reload
