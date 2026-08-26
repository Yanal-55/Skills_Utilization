#!/bin/bash
VAULT_TOKEN="${VAULT_TOKEN:-}"

if [ -z "$VAULT_TOKEN" ]; then
  echo "Error: VAULT_TOKEN environment variable is not set."
  exit 1
fi

echo "==> Fetching secrets from Vault..."
SECRETS=$(curl -s --header "X-Vault-Token: $VAULT_TOKEN" \
  http://127.0.0.1:8200/v1/secret/data/skills_app)

DB_URL=$(echo $SECRETS | jq -r '.data.data.DATABASE_URL')
SECRET_KEY=$(echo $SECRETS | jq -r '.data.data.SECRET_KEY')

cat <<EOT > .env
DATABASE_URL=$DB_URL
SECRET_KEY=$SECRET_KEY
EOT

echo "==> Success! Secrets written to ./.env"
