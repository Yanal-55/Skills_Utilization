#!/bin/bash
VAULT_ADDR='http://vault:8200'
VAULT_TOKEN='root'
SECRET_PATH="kv/project3"
ENV_FILE='/home/aau/Desktop/Skills_Utilization/.env'

export VAULT_ADDR
export VAULT_TOKEN

echo "Retrieving secrets from Vault..."
SECRETS=$(vault kv get -format=json $SECRET_PATH)
if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + .value' > $ENV_FILE
if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

echo "Secrets loaded successfully!"
