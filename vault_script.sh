#!/bin/bash

# Variables
CONTAINER_NAME="skills_utilization-vault-1"
SECRET_PATH="kv/project3"
ENV_FILE="./.env"

# Ensure Vault service is up
echo "Ensuring Vault service is up..."
docker compose up -d vault
sleep 2

# Retrieve secrets directly inside the container via docker exec
echo "Retrieving secrets from Vault..."
SECRETS=$(docker exec -e VAULT_ADDR='http://127.0.0.1:8200' -e VAULT_TOKEN='root' "$CONTAINER_NAME" vault kv get -format=json $SECRET_PATH)

# Check if retrieval was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

# Extract data and save to .env file locally
echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + .value' > "$ENV_FILE"

# Check if .env file was created successfully
if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

# Run remaining Docker containers with .env file
echo "Running Docker containers..."
docker compose --env-file "$ENV_FILE" up -d --remove-orphans
