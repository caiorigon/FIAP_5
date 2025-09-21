from fastapi import FastAPI, UploadFile, File, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from dotenv import load_dotenv
import json
from PIL import Image
from openai import OpenAI
import base64
import io
import os
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

# Initialize OpenAI client
openai_client = OpenAI()


# Initialize Gemini client (using OpenAI-compatible interface)
def get_gemini_client():
    try:
        return OpenAI(
            api_key=os.environ.get("GOOGLE_API_KEY"),
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/",
        )
    except Exception as e:
        logger.error(f"Failed to initialize Gemini client: {e}")
        return None


app = FastAPI()

security = HTTPBearer()


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    if token != os.getenv("API_AUTH_TOKEN"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing token",
        )


def analyze_image_with_openai(payload, format_type):
    """Analyze image using OpenAI GPT-4o"""
    try:
        logger.info("Attempting analysis with OpenAI GPT-4o")
        response = openai_client.chat.completions.create(
            model="gpt-4o",
            response_format={"type": "json_object"},
            messages=payload,
        )
        content = response.choices[0].message.content
        return json.loads(content)  # type: ignore
    except Exception as e:
        logger.error(f"OpenAI analysis failed: {e}")
        raise e


def analyze_image_with_gemini(payload):
    """Analyze image using Gemini as fallback"""
    try:
        logger.info("Attempting analysis with Gemini as fallback")
        gemini_client = get_gemini_client()

        if not gemini_client:
            raise Exception("Gemini client not available")

        # Gemini might use slightly different model names
        response = gemini_client.chat.completions.create(
            model="gemini-2.0-flash",
            response_format={"type": "json_object"},
            messages=payload,
        )

        content = response.choices[0].message.content
        return json.loads(content)  # type: ignore
    except Exception as e:
        logger.error(f"Gemini analysis failed: {e}")
        raise e


def analyze_image_with_fallback(payload, format_type):
    """Try OpenAI first, then fallback to Gemini"""

    # Try OpenAI first
    try:
        return analyze_image_with_openai(payload, format_type)
    except Exception as openai_error:
        logger.warning(
            f"OpenAI failed, trying Gemini fallback. OpenAI error: {openai_error}"
        )

        # Try Gemini as fallback
        try:
            return analyze_image_with_gemini(payload)
        except Exception as gemini_error:
            logger.error(f"Both OpenAI and Gemini failed. Gemini error: {gemini_error}")
            # Re-raise the original OpenAI error since it's the primary service
            raise HTTPException(
                status_code=500,
                detail=f"Both AI services failed. OpenAI: {str(openai_error)}, Gemini: {str(gemini_error)}",
            )


@app.post("/analyze-diagram")
async def analyze_diagram(
    image: UploadFile = File(...),
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    """
    Receives a diagram and a prompt, find potential STRIDE problems in the architecture based on our internal knowledge base.
    """
    verify_token(credentials)

    try:
        image_bytes = await image.read()

        prompt = """
You are a cloud security expert specializing in STRIDE threat modeling. Analyze the provided cloud architecture diagram and perform a comprehensive security assessment.

INSTRUCTIONS:
1. Carefully examine the diagram to identify the cloud provider and architecture components
2. Perform STRIDE analysis (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege)
3. For each component, identify the MOST CRITICAL security threat based on STRIDE methodology
4. Provide actionable mitigation strategies

STRIDE THREAT LEVELS:
- High: Critical security vulnerabilities that could lead to system compromise, data breaches, or service outages
- Medium: Significant security risks that could impact confidentiality, integrity, or availability
- Low: Minor security concerns that should be addressed but pose limited risk
- None: No significant STRIDE threats identified

RESPONSE FORMAT:
You MUST return ONLY a valid JSON object. Do not include any text before or after the JSON.

If you can analyze the diagram successfully, return:
{
  "title": "Descriptive title of the architecture (e.g., 'E-commerce Web Application on AWS')",
  "cloud": "Cloud provider (AWS/Azure/GCP/Multi-cloud/On-premises/Unknown)",
  "description": "Brief description of what the architecture does and its main purpose (2-3 sentences)",
  "components": [
    {
      "name": "Component name (be specific, e.g., 'Application Load Balancer', not just 'Load Balancer')",
      "description": "What this component does in 1-2 sentences",
      "threat": {
        "description": "Detailed description of the most critical STRIDE threat for this component, or empty string if none",
        "threat_type": "Which STRIDE category (Spoofing/Tampering/Repudiation/Information Disclosure/Denial of Service/Elevation of Privilege)",
        "threat_level": "High/Medium/Low/None",
        "possible_mitigation": "Specific, actionable mitigation steps, or empty string if threat level is None"
      }
    }
  ]
}

If you cannot analyze the diagram (blurry, not a cloud architecture, etc.), return:
{
  "error": "Specific reason why the diagram cannot be analyzed (e.g., 'Image is too blurry to identify components', 'This appears to be a network diagram, not a cloud architecture', etc.)"
}

EXAMPLES OF GOOD COMPONENT ANALYSIS:

Example 1 - High Threat:
{
  "name": "Amazon RDS Database",
  "description": "Managed relational database storing customer and transaction data",
  "threat": {
    "description": "Database is accessible from multiple subnets without proper access controls, potentially allowing unauthorized data access",
    "threat_type": "Information Disclosure",
    "threat_level": "High",
    "possible_mitigation": "Implement VPC security groups, enable encryption at rest and in transit, use IAM database authentication, and restrict database access to specific application subnets only"
  }
}

Example 2 - No Threat:
{
  "name": "CloudFront CDN",
  "description": "Content delivery network for static assets with proper SSL termination",
  "threat": {
    "description": "",
    "threat_type": "",
    "threat_level": "None",
    "possible_mitigation": ""
  }
}

IMPORTANT GUIDELINES:
- Be specific about component names (use actual service names when identifiable)
- Focus on the MOST CRITICAL threat per component, not all possible threats
- Ensure threat_level matches the severity of the description
- Provide concrete, implementable mitigation strategies
- If unsure about a specific service, use generic but accurate descriptions
- Empty strings for threat fields when threat_level is "None"
- Do not make assumptions about security configurations unless clearly visible in the diagram

Analyze the provided cloud architecture diagram now:
"""
        img = Image.open(io.BytesIO(image_bytes))
        format_type = img.format.lower()  # type: ignore # e.g., 'jpeg', 'png'
        if format_type == "jpg":
            format_type = "jpeg"

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
                            "url": f"data:image/{format_type};base64,{base64_image}"
                        },
                    },
                ],
            }
        ]

        # Use the fallback mechanism
        result_json = analyze_image_with_fallback(payload, format_type)

        if "error" in result_json:
            logger.error("Analysis returned error result")
            raise HTTPException(status_code=400, detail=result_json["error"])

        return result_json

    except Exception as e:
        logger.error(f"Exception in analyze_diagram: {e}")
        if isinstance(e, HTTPException):
            raise e
        else:
            raise HTTPException(status_code=500, detail=str(e))


# Additional endpoint to test which AI service is available
@app.get("/health/ai-services")
async def check_ai_services(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    """Check which AI services are available"""
    verify_token(credentials)

    services_status = {}

    # Check OpenAI
    try:
        openai_client.models.list()
        services_status["openai"] = "available"
    except Exception as e:
        services_status["openai"] = f"unavailable: {str(e)}"

    # Check Gemini
    try:
        gemini_client = get_gemini_client()
        if gemini_client:
            gemini_client.models.list()
            services_status["gemini"] = "available"
        else:
            services_status["gemini"] = "unavailable: client initialization failed"
    except Exception as e:
        services_status["gemini"] = f"unavailable: {str(e)}"

    return services_status
