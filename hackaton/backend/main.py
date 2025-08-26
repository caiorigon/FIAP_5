from fastapi import FastAPI, UploadFile, File, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
import json
from PIL import Image, ImageDraw
from openai import OpenAI
import base64
import io
import os

load_dotenv()
client = OpenAI()
# client_gemini = OpenAI(
#     api_key=os.environ.get("GOOGLE_API_KEY"),
#     base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
# )

app = FastAPI()

security = HTTPBearer()


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    if token != os.getenv("API_AUTH_TOKEN"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing token",
        )


@app.post("/analyze-diagram")
async def analyze_diagram(
    image: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    """
    Receives a diagram and a prompt, uses RAG to find potencial STRIDE problems in the architecture based on our internal knowledge base.
    """
    verify_token(credentials)

    try:
        image_bytes = await image.read()

        prompt = """
analyze this cloud software architecture diagram and identify what is it doing, what cloud it is in.
Make a full STRIDE analysis of the architecture, identifying potential security threats.
Make a list of all the main components in the architecture, with its name, short description, and the highest identified threat.
The threat is a potential STRIDE security threat identified in the architecture, with the description of the threat, threat_level, and possible mitigation.
If the component doesn`t have a threat, return the component with the empty threat.

Return ONLY a valid JSON object with the following structure OR a valid JSON containing an error message:
Valid JSON structure:
{
  "title": "Title of the architecture diagram",
  "cloud": "Cloud provider (e.g., AWS, Azure, GCP)",
  "description": "description of the architecture",
  "components": [ "list of main components in the architecture, with the following structure:"
    {
      "name": "Name of the cloud component",
      "description": "Very short description of what this components is or do
      "threat": "the most dangerous threat identified in the component, with the following structure:"
        {
          "description": "Description of the threat or empty if none",
          "threat_level": "High/Medium/Low/none",
          "possible_mitigation": "Description of the possible mitigation proposed or empty if none"
        }
    }
  ]
}

Error JSON structure:
{
    "error": "Description of the error"
}
"""
        img = Image.open(io.BytesIO(image_bytes))
        format = img.format.lower()  # type: ignore # e.g., 'jpeg', 'png'
        if format == "jpg":
            format = "jpeg"

        # Encode image to base64
        base64_image = base64.b64encode(image_bytes).decode("utf-8")

        payload = [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/{format};base64,{base64_image}"
                        },
                    },
                ],
            }
        ]

        response = client.chat.completions.create(
            model="gpt-4o",
            response_format={"type": "json_object"},
            messages=payload,  # type: ignore
        )

        content = response.choices[0].message.content

        result_json = json.loads(content)  # type: ignore

        # url = edit_image_openai(image_bytes, result_json["title"])
        # result_json["image_url"] = url

        # edit_image_gemini(base64_image)

        if "error" in result_json:
            print("error")
            raise HTTPException(status_code=400, detail=result_json["error"])

        return result_json
    except Exception as e:
        print("exception")
        if isinstance(e, HTTPException):
            print("http exception")
            raise e
        else:
            print("other exception")
            raise HTTPException(status_code=500, detail=str(e))


def edit_image_openai(image_bytes, components):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert("RGBA")  # Convert to RGBA
        png_bytes_io = io.BytesIO()
        img.save(png_bytes_io, format="PNG")
        png_bytes_io.seek(0)

        png_file = ("image.png", png_bytes_io, "image/png")

        # short_components = [
        #     {
        #         "name": comp["name"],
        #         "threat_level": comp["threat"]["threat_level"],
        #     }
        #     for comp in components
        # ]
        short_prompt = (
            "remove every text from this image"
            # f"""Given the following "Components" in a cloud architecture diagram, draw a threat level diagram highlighting the components with colors based on their threat levels (Red for High, Orange for Medium, Green for Low).
            # "Components": {json.dumps(short_components)}"""
        )

        print(short_prompt)
        response = client.images.edit(
            image=png_file, prompt=short_prompt, model="dall-e-2", response_format="url"
        )

        image_url = response.data[0].url  # type: ignore
        print(image_url)
        return image_url
    except Exception as e:
        print(f"Error sending image: {str(e)}")


# def edit_image_gemini(base64_image):
#     try:
#         client_gemini = OpenAI(
#             api_key=os.environ.get("GOOGLE_API_KEY"),
#             base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
#         )

#         response = client_gemini.chat.completions.create(
#             model="gemini-2.0-flash",
#             messages=[
#                 {
#                     "role": "user",
#                     "content": [
#                         {
#                             "type": "text",
#                             "text": "return a json with the coordinates (x1,y1,x2,y2) of the bounding boxes of every component in the image.",
#                         },
#                         {
#                             "type": "image_url",
#                             "image_url": {
#                                 "url": f"data:image/jpeg;base64,{base64_image}"
#                             },
#                         },
#                     ],
#                 }
#             ],
#         )

#         print(response.choices[0].message.content)  # type: ignore
#     except Exception as e:
#         print(f"Error sending image to Gemini: {str(e)}")


# def draw_bounding_box(image, json_data):
#     try:
#         draw = ImageDraw.Draw(image)
#         colors = {
#             "High": (255, 0, 0, 180),  # Red
#             "Medium": (255, 165, 0, 180),  # Orange
#             "Low": (0, 255, 0, 180),  # Green (not used in this case)
#         }
#         for component in json_data["components"]:
#             x1, y1, x2, y2 = component["bounding_box"]
#             lvl = component["threat"]["threat_level"]
#             color = colors[lvl]
#             print(x1, x2, y1, y2, lvl, color)
#             draw.rectangle([(x1, y1), (x2, y2)], outline=color)
#             draw.text(
#                 (x1, y1 - 10), f"{component['name']} - Threat level: {lvl}", fill=color
#             )

#         output_threat_img = "image_with_threat.png"
#         image.save(output_threat_img)
#     except Exception as e:
#         print(f"Error drawing threat diagram: {e}")
