#! /usr/bin/bash

# Lab: How to deploy a secure MCP server on Cloud Run
# https://codelabs.developers.google.com/codelabs/cloud-run/how-to-deploy-a-secure-mcp-server-on-cloud-run#6

# gcloud auth login

# gcloud projects create mcp-server
gcloud config set project mcp-server

gcloud config set run/region us-central1

# list all your project ids
# gcloud projects list | awk '/PROJECT_ID/{print $2}'

gcloud services enable \
run.googleapis.com \
artifactregistry.googleapis.com \
cloudbuild.googleapis.com

# Create a Python project with the uv tool to generate a pyproject.toml file
# uv init --description "zoo mcp server" --bare --python 3.13

# add FastMCP as a dependency in the pyproject.toml file
# uv add fastmcp==2.12.4 --no-sync

# Create a service account named mcp-server-sa
gcloud iam service-accounts create mcp-server-sa --display-name="MCP Server Service Account"

export PROJECT_ID=$(gcloud config get-value project)
echo "$PROJECT_ID"

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
echo "$PROJECT_NUMBER"

gcloud projects add-iam-policy-binding $PROJECT_ID \
	--member=user:$(gcloud config get-value account) \
	--role='roles/run.invoker'

gcloud run deploy zoo-mcp-server \
	--service-account=mcp-server-sa@$PROJECT_ID.iam.gserviceaccount.com \
	--no-allow-unauthenticated \
	--region=us-central1 \
	--source=. \
	--labels=dev-tutorial=codelab-mcp

export ID_TOKEN=$(gcloud auth print-identity-token)
echo "$ID_TOKEN"

# gemini
# /mcp
# Where can I find penguins?

# To verify that your Cloud Run MCP server was called, check the service logs
# gcloud run services logs read zoo-mcp-server --region us-central1 --limit=5

# gcloud run deploy zoo-mcp-server \
#     --region=us-central1 \
#     --source=. \
#     --labels=dev-tutorial=codelab-mcp

# export ID_TOKEN=$(gcloud auth print-identity-token)
# echo "$ID_TOKEN"

# gemini --model=gemini-2.5-flash-lite
# /find lions

# gcloud projects delete $PROJECT_ID
