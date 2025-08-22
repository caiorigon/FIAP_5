# main_llamaindex.py
from fastapi import FastAPI, UploadFile, File
from pathlib import Path
from dotenv import load_dotenv
import json
from PIL import Image, ImageDraw

# LlamaIndex Imports
from llama_index.core import SimpleDirectoryReader, VectorStoreIndex, Settings
from llama_index.core.llms import ChatMessage, TextBlock, ImageBlock, MessageRole
from llama_index.llms.openai import OpenAI

load_dotenv()
# --- Configure LlamaIndex Settings to use Gemini ---
Settings.llm = OpenAI(model="gpt-4o")
# Settings.embed_model = OpenAIEmbedding(
#     model_name=OpenAIEmbeddingModelType.TEXT_EMBED_3_LARGE
# )

# --- Setup: This part would run once when your server starts ---
# Create a dummy knowledge base for our rules
# Path("knowledge").mkdir(exist_ok=True)
# with open("knowledge/rules.md", "w") as file:
#     file.write(
#         """
# # Our Company's Architectural Rules
# 1. Identify
#     Understand the organization’s environment, assets, systems, and risks.
#     Activities: asset management, risk assessment, business environment analysis, governance.

# 2. Protect
#     Develop and implement safeguards to limit or contain the impact of a potential event.
#     Activities: access control, awareness training, data security, protective technology, maintenance.

# 3. Detect
#     Identify the occurrence of a cybersecurity event in a timely manner.
#     Activities: continuous monitoring, detection processes, anomaly identification.

# 4. Respond
#     Take action regarding a detected cybersecurity incident.
#     Activities: incident response planning, analysis, communication, mitigation, improvements.

# 5. Recover
#     Restore capabilities or services that were impaired due to an incident.
#     Activities: recovery planning, improvements, communications, business continuity.
# """
#     )

# # Load data and build the index
# documents = SimpleDirectoryReader("./knowledge").load_data()
# index = VectorStoreIndex.from_documents(documents)
# # # --- End of Setup ---

app = FastAPI()


@app.post("/analyse-diagram")
async def analyse_diagram(image_file: UploadFile = File(...)):
    """
    Receives a diagram and a prompt, uses RAG to find potencial STRIDE problems in the architecture based on our internal knowledge base.
    """
    try:
        image_bytes = await image_file.read()

        img = Image.open(image_file.file)
        prompt = f"""
Analyse this cloud software architecture diagram and identify what is it doing, what cloud it is in and the main components of this image.
Make a full STRIDE analysis of the architecture, identifying potential security threats.
A list of main components in the architecture, with the coordinates of the bounding box of the components in the image and the threats: A list of potential security threats identified in the architecture, with the description, threat_level, and possible mitigation.

Return ONLY a valid JSON object with the following structure and nothing else:
{{
  "title": "Title of the architecture diagram",
  "cloud": "Cloud provider (e.g., AWS, Azure, GCP)",
  "description": "description of the architecture",
  "components": [
    {{
      "name": "Name of the cloud component",
      "bounding_box": "Return a list of integers [x1, y1, x2, y2] that is the exact pixel coordinates of the location of the box area around the component in the diagram, considering the top left corner as (x=0, y=0) and the bottom right corner as (x={img.width}, y={img.height})."
      "threat": "the most dangerous threats identified in the architecture, with the following structure:"
        {{
          "description": "Description of the threat",
          "threat_level": "High/Medium/Low",
          "possible_mitigation": "Description of the possible mitigation proposed"
        }}
    }}
  ]
}}
"""

        # Query with both the image and text. LlamaIndex handles the rest.
        message = [
            ChatMessage(
                role=MessageRole.USER,
                blocks=[
                    ImageBlock(image=image_bytes),
                    TextBlock(text=prompt),
                ],
            )
        ]
        response = Settings.llm.chat(message)

        response_str = response.message.blocks[0].text  # type: ignore

        # Remove code fences if present
        if response_str.startswith("```json"):
            response_str = (
                response_str.replace("```json", "").replace("```", "").strip()
            )
        try:
            response_json = json.loads(response_str)

            # draw_bounding_box(img, response_json)

            return {
                "result": response_json,
            }
        except Exception as e:
            print("Error parsing JSON response:", str(e))
            return {response_str}

    except Exception as e:
        return {"error": str(e)}


# def draw_bounding_box(image, json_data):
#     try:
#         draw = ImageDraw.Draw(image)
#         colors = {
#             "High": (255, 0, 0, 180),  # Red
#             "Medium": (255, 165, 0, 180),  # Orange
#             "Low": (0, 255, 0, 180),  # Green (not used in this case)
#         }
#         for component in json_data['components']:
#             x1, y1, x2, y2 = component["bounding_box"]
#             lvl = component["threat"]["threat_level"]
#             color = colors[lvl]
#             print(x1,x2,y1,y2,lvl,color)
#             draw.rectangle([(x1, y1), (x2, y2)], outline=color)
#             draw.text((x1, y1 - 10), f"{component['name']} - Threat level: {lvl}", fill=color)

#         output_threat_img = "image_with_threat.png"
#         image.save(output_threat_img)
#     except Exception as e:
#         print(f"Error drawing threat diagram: {e}")
