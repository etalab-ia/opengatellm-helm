#!/bin/bash

# OpenGateLLM Bootstrap Script
# - Logs in as the bootstrap admin user
# - Creates an API key and prints it.
# - Creates the router/provider for the Ministral model served by the

set -e

BASE_URL="${BASE_URL:-http://localhost:8000}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-changeme}"

ROUTER_NAME="mistralai/Ministral-3-3B-Instruct-2512"
ROUTER_TYPE="text-generation"
PROVIDER_TYPE="vllm"
PROVIDER_URL="${PROVIDER_URL:-http://opengatellm-stack-router-service/}"
PROVIDER_KEY="${PROVIDER_KEY:-changeme}"
PROVIDER_MODEL_NAME="mistralai/Ministral-3-3B-Instruct-2512"

echo "=== OpenGateLLM Bootstrap ==="
echo "Base URL: ${BASE_URL}"
echo ""

# 1. Login as bootstrap admin
echo "1. Logging in as ${ADMIN_EMAIL}..."
LOGIN_BODY=$(cat <<EOF
{"email": "${ADMIN_EMAIL}", "password": "${ADMIN_PASSWORD}"}
EOF
)
LOGIN_RESPONSE=$(curl -sf -X POST "${BASE_URL}/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d "$LOGIN_BODY") || {
  echo "   ✗ Login failed. Check ADMIN_EMAIL / ADMIN_PASSWORD and that the API is reachable at ${BASE_URL}."
  exit 1
}

SESSION_KEY=$(echo "$LOGIN_RESPONSE" | jq -r '.key')
if [ "$SESSION_KEY" = "null" ] || [ -z "$SESSION_KEY" ]; then
  echo "   ✗ Login response missing key: $LOGIN_RESPONSE"
  exit 1
fi
echo "   ✓ Logged in"

# 2. Create API key
echo "2. Creating API key..."
KEY_RESPONSE=$(curl -sf -X POST "${BASE_URL}/v1/me/keys" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SESSION_KEY}" \
  -d '{"name": "bootstrap-key", "expires": null}') || {
  echo "   ✗ Failed to create API key"
  exit 1
}

API_KEY=$(echo "$KEY_RESPONSE" | jq -r '.key // .token')
if [ "$API_KEY" = "null" ] || [ -z "$API_KEY" ]; then
  echo "   ✗ API key response missing key/token: $KEY_RESPONSE"
  exit 1
fi
echo "   ✓ API key created"

# 3. Find or create the Ministral router
echo "3. Setting up router '${ROUTER_NAME}'..."
ROUTERS=$(curl -sf -H "Authorization: Bearer ${API_KEY}" "${BASE_URL}/v1/admin/routers")
ROUTER_ID=$(echo "$ROUTERS" | jq -r --arg n "$ROUTER_NAME" '.data[] | select(.name == $n) | .id' | head -n 1)

if [ -z "$ROUTER_ID" ] || [ "$ROUTER_ID" = "null" ]; then
  ROUTER_BODY=$(cat <<EOF
{"name": "${ROUTER_NAME}", "type": "${ROUTER_TYPE}"}
EOF
)
  CREATE_ROUTER=$(curl -sf -X POST "${BASE_URL}/v1/admin/routers" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${API_KEY}" \
    -d "$ROUTER_BODY") || {
    echo "   ✗ Failed to create router"
    exit 1
  }
  ROUTER_ID=$(echo "$CREATE_ROUTER" | jq -r '.id')
  if [ -z "$ROUTER_ID" ] || [ "$ROUTER_ID" = "null" ]; then
    echo "   ✗ Router response missing id: $CREATE_ROUTER"
    exit 1
  fi
  echo "   ✓ Router created (id=${ROUTER_ID})"
else
  echo "   ✓ Router already exists (id=${ROUTER_ID})"
fi

# 4. Find or create the Ministral provider on that router
echo "4. Setting up provider..."
PROVIDERS=$(curl -sf -H "Authorization: Bearer ${API_KEY}" "${BASE_URL}/v1/admin/providers")
EXISTING_PROVIDER=$(echo "$PROVIDERS" \
  | jq -r --argjson r "$ROUTER_ID" --arg url "$PROVIDER_URL" --arg name "$PROVIDER_MODEL_NAME" \
      '.data[] | select(.router_id == $r and .url == $url and .model_name == $name) | .id' \
  | head -n 1)

if [ -z "$EXISTING_PROVIDER" ] || [ "$EXISTING_PROVIDER" = "null" ]; then
  PROVIDER_BODY=$(cat <<EOF
{
  "router_id": ${ROUTER_ID},
  "type": "${PROVIDER_TYPE}",
  "url": "${PROVIDER_URL}",
  "key": "${PROVIDER_KEY}",
  "model_name": "${PROVIDER_MODEL_NAME}",
  "timeout": 300,
  "model_hosting_zone": "FRA",
  "model_total_params": 3,
  "model_active_params": 3
}
EOF
)
  CREATE_PROVIDER=$(curl -sf -X POST "${BASE_URL}/v1/admin/providers" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${API_KEY}" \
    -d "$PROVIDER_BODY") || {
    echo "   ✗ Failed to create provider"
    exit 1
  }
  PROVIDER_ID=$(echo "$CREATE_PROVIDER" | jq -r '.id')
  if [ -z "$PROVIDER_ID" ] || [ "$PROVIDER_ID" = "null" ]; then
    echo "   ✗ Provider response missing id: $CREATE_PROVIDER"
    exit 1
  fi
  echo "   ✓ Provider created (id=${PROVIDER_ID})"
else
  echo "   ✓ Provider already exists (id=${EXISTING_PROVIDER})"
fi

# 5. Verify the API key can list models
echo "5. Listing models visible with the new API key..."
MODELS=$(curl -sf -H "Authorization: Bearer ${API_KEY}" "${BASE_URL}/v1/models" || echo '{}')
MODEL_COUNT=$(echo "$MODELS" | jq '.data | length // 0')
if [ "$MODEL_COUNT" = "0" ]; then
  echo "   ⚠ API key sees 0 models (provider may still be initialising)."
else
  echo "$MODELS" | jq -r '.data[] | "      - \(.id)"'
fi

cat <<EOF

=== Done ===

API key: ${API_KEY}

Try a chat completion:
  curl -X POST -H "Authorization: Bearer ${API_KEY}" -H "Content-Type: application/json" \\
    ${BASE_URL}/v1/chat/completions \\
    -d '{"model": "${ROUTER_NAME}", "messages": [{"role":"system","content":"You are a helpful assistant."},{"role":"user","content":"Hey how are you ?"}]}'
EOF
