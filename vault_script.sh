#!/bin/bash
set -e

SECRET_PATH="kv/project3"
ENV_FILE="/env_share/.env"

# Wait until Vault is ready to accept connections
echo "Waiting for Vault at $VAULT_ADDR..."
until curl -s "$VAULT_ADDR/v1/sys/health" > /dev/null; do
  sleep 1
done

# Check if the secret path exists; if missing, seed dev defaults
if ! vault kv get "$SECRET_PATH" > /dev/null 2>&1; then
  echo "Secret path missing. Seeding dev secrets to $SECRET_PATH..."
  vault secrets enable -path=kv kv-v2 2>/dev/null || true
  vault kv put "$SECRET_PATH" \
    POSTGRES_DB="skills_db" \
    POSTGRES_USER="postgres" \
    POSTGRES_PASSWORD="devpassword123"
fi

# Retrieve secrets from Vault
echo "Retrieving secrets from Vault..."
SECRETS=$(vault kv get -format=json "$SECRET_PATH")

# Extract KV pairs and write to .env inside the mounted share directory
echo "Saving secrets to $ENV_FILE..."
echo "$SECRETS" | jq -r '.data.data | to_entries[] | .key + "=" + .value' > "$ENV_FILE"

echo "Secrets initialized successfully!"
