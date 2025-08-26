#!/bin/bash

# --- Configuration ---
PROJECT_ID="archalyzer"
SERVICE_NAME="backend-api"
REGION="us-central1"

# --- Authenticate (if not already authenticated) ---
# For automated scripts, consider using a service account:
# gcloud auth activate-service-account --key-file=/path/to/keyfile.json

gcloud config set project "$PROJECT_ID"

gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME

# --- Deploy to Cloud Run ---
echo "Deploying $SERVICE_NAME to Cloud Run in $REGION..."
gcloud run deploy "$SERVICE_NAME" \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --region "$REGION" \
  --allow-unauthenticated \
  --quiet # Use --quiet for non-interactive deployment

if [ $? -eq 0 ]; then
  echo "Deployment successful!"
  gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format="value(status.url)"
else
  echo "Deployment failed."
  exit 1
fi