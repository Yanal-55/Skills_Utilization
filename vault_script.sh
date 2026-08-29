#!/bin/bash

# Variables
VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN='root'
SECRET_PATH='kv/project3'
ENV_FILE='./.env'

export VAULT_ADDR
export VAULT_TOKEN

# Retrieve secrets from Vault
echo "Retrieving secrets from Vault..."
SECRETS=$(vault kv get -format=json $SECRET_PATH)

# Check if retrieval was successful
if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

# Extract data and save to .env file
echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + .value' > "$ENV_FILE"

# Check if .env file was created successfully
if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

# Run Docker with .env file
echo "Running Docker container..."
docker compose --env-file "$ENV_FILE" up -d
