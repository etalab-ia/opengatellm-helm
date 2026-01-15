#!/bin/bash

# OpenGateLLM Bootstrap Script
# This script bootstraps OpenGateLLM by creating an admin role with full access, an admin user with that role, and an API key for that user. It also creates missing providers and verifies the API key can access models.

set -e  # Exit on error

# Configuration
BASE_URL="http://localhost:8000"
ADMIN_API_KEY="changeme"

echo "=== OpenGateLLM Bootstrap Script ==="
echo "Base URL: ${BASE_URL}"
echo ""

# ============================================================================
# 1. List and Verify Existing Routers
# ============================================================================
echo "1. Checking existing routers/models..."
ROUTERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/routers")

# Verify we have routers
ROUTER_COUNT=$(echo $ROUTERS | jq '.data | length')
if [ "$ROUTER_COUNT" -eq "0" ]; then
  echo "   ⚠ WARNING: No routers found!"
  echo "   Routers must exist before creating role limits."
  echo "   The script will continue but users won't be able to access any models."
  echo ""
else
  echo "   ✓ Found ${ROUTER_COUNT} router(s):"
  echo "$ROUTERS" | jq -r '.data[] | "      - Router ID \(.id): \(.name) (type: \(.type), providers: \(.providers))"'
  echo ""
fi

# ============================================================================
# 2. Create Missing Providers
# ============================================================================
echo "2. Creating missing providers..."

# Check if albert-testbed router exists and needs a provider
ALBERT_ROUTER_ID=$(echo $ROUTERS | jq -r '.data[] | select(.name == "albert-testbed") | .id')
if [ -n "$ALBERT_ROUTER_ID" ] && [ "$ALBERT_ROUTER_ID" != "null" ]; then
  ALBERT_PROVIDERS=$(echo $ROUTERS | jq -r ".data[] | select(.id == $ALBERT_ROUTER_ID) | .providers")

  if [ "$ALBERT_PROVIDERS" = "0" ]; then
    echo "   Creating provider for albert-testbed (Router ID ${ALBERT_ROUTER_ID})..."
    PROVIDER_ALBERT=$(curl -s -X POST "${BASE_URL}/v1/admin/providers" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${ADMIN_API_KEY}" \
      -d '{
        "router": '${ALBERT_ROUTER_ID}',
        "type": "vllm",
        "url": "http://albert-testbed.etalab.gouv.fr:8000",
        "key": "changeme",
        "model_name": "gemma3:1b",
        "timeout": 300,
        "model_carbon_footprint_zone": "WOR",
        "model_carbon_footprint_total_params": 0,
        "model_carbon_footprint_active_params": 0
      }')

    PROVIDER_ALBERT_ID=$(echo $PROVIDER_ALBERT | jq -r '.id')
    if [ "$PROVIDER_ALBERT_ID" != "null" ]; then
      echo "   ✓ Provider created for albert-testbed with ID: ${PROVIDER_ALBERT_ID}"
    else
      echo "   ✗ Failed to create provider. Response: $PROVIDER_ALBERT"
    fi
  else
    echo "   ✓ Provider already exists for albert-testbed (Router ID ${ALBERT_ROUTER_ID})"
  fi
else
  echo "   ⚠ Router 'albert-testbed' not found, skipping provider creation"
fi

# Check if router ID 3 exists and needs a provider
ROUTER_3_EXISTS=$(echo $ROUTERS | jq -r '.data[] | select(.id == 3) | .id')
if [ -n "$ROUTER_3_EXISTS" ]; then
  ROUTER_3_PROVIDERS=$(echo $ROUTERS | jq -r '.data[] | select(.id == 3) | .providers')

  if [ "$ROUTER_3_PROVIDERS" = "0" ]; then
    echo "   Creating provider for mistralai/Mistral-Small-3.2-24B-Instruct-2506 (Router ID 3)..."
    PROVIDER_3=$(curl -s -X POST "${BASE_URL}/v1/admin/providers" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${ADMIN_API_KEY}" \
      -d '{
        "router": 3,
        "type": "vllm",
        "url": "http://opengatellm-stack-router-service/",
        "key": "changeme",
        "model_name": "mistralai/Mistral-Small-3.2-24B-Instruct-2506",
        "timeout": 300,
        "model_carbon_footprint_zone": "WOR",
        "model_carbon_footprint_total_params": 0,
        "model_carbon_footprint_active_params": 0
      }')

    PROVIDER_3_ID=$(echo $PROVIDER_3 | jq -r '.id')
    if [ "$PROVIDER_3_ID" != "null" ]; then
      echo "   ✓ Provider created for Mistral-Small with ID: ${PROVIDER_3_ID}"
    else
      echo "   ✗ Failed to create provider. Response: $PROVIDER_3"
    fi
  else
    echo "   ✓ Provider already exists for Mistral-Small (Router ID 3)"
  fi
else
  echo "   ⚠ Router ID 3 not found, skipping provider creation"
fi

echo ""

# ============================================================================
# 3. Verify All Providers
# ============================================================================
echo "3. Verifying all providers..."
PROVIDERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/providers")

PROVIDER_COUNT=$(echo $PROVIDERS | jq '.data | length')
if [ "$PROVIDER_COUNT" -eq "0" ]; then
  echo "   ⚠ WARNING: No providers found! Models won't be accessible."
else
  echo "   ✓ Found ${PROVIDER_COUNT} provider(s):"
  echo "$PROVIDERS" | jq -r '.data[] | "      - Provider ID \(.id): \(.model_name) -> \(.url) (router_id: \(.router_id))"'
fi
echo ""

# ============================================================================
# 4. Create Admin Role with Initial Empty Limits
# ============================================================================
echo "4. Creating admin role..."
ROLE_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/admin/roles" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  -d '{
    "name": "Admin Role",
    "permissions": ["admin", "create_public_collection", "read_metric", "provide_models"],
    "limits": []
  }')

ROLE_ID=$(echo $ROLE_RESPONSE | jq -r '.id')
if [ "$ROLE_ID" = "null" ] || [ -z "$ROLE_ID" ]; then
  echo "   ✗ Failed to create role. Response: $ROLE_RESPONSE"
  exit 1
fi
echo "   ✓ Admin role created with ID: ${ROLE_ID}"
echo ""

# ============================================================================
# 5. Add Router Limits to Admin Role (ALL FOUR LIMIT TYPES)
# ============================================================================
echo "5. Adding router access to admin role..."

# Refresh router list to get latest state
ROUTERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/routers")

ROUTER_COUNT=$(echo $ROUTERS | jq '.data | length')

if [ "$ROUTER_COUNT" -eq "0" ]; then
  echo "   ⚠ WARNING: No routers available. Role will have empty limits."
  echo "   Users with this role won't be able to see or access any models!"
  LIMITS="[]"
else
  # Build limits array for ALL routers with ALL FOUR limit types
  # This ensures users can both LIST models and MAKE REQUESTS
  # Types: rpm (requests per minute), rpd (requests per day),
  #        tpm (tokens per minute), tpd (tokens per day)
  # Value: null means unlimited access
  # Use -c flag for compact JSON output (no newlines)
  LIMITS=$(echo $ROUTERS | jq -c '[.data[] | . as $router | ["rpm", "rpd", "tpm", "tpd"] | .[] | {router: $router.id, type: ., value: null}]')

  LIMIT_COUNT=$(echo $LIMITS | jq 'length')
  echo "   ✓ Created ${LIMIT_COUNT} limit entries (4 types × ${ROUTER_COUNT} routers)"
fi

# Update role with router limits
UPDATE_ROLE=$(curl -s -X PATCH "${BASE_URL}/v1/admin/roles/${ROLE_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  -d '{
    "name": "Admin Role",
    "permissions": ["admin", "create_public_collection", "read_metric", "provide_models"],
    "limits": '"${LIMITS}"'
  }')


# ============================================================================
# 6. Create Admin User
# ============================================================================
echo "6. Creating admin user..."
USER_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/admin/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePassword123!",
    "name": "AdminTest",
    "role": '${ROLE_ID}'
  }')

USER_ID=$(echo $USER_RESPONSE | jq -r '.id')
if [ "$USER_ID" = "null" ] || [ -z "$USER_ID" ]; then
  echo "   ✗ Failed to create user. Response: $USER_RESPONSE"
  exit 1
fi
echo "   ✓ User created with ID: ${USER_ID}"
echo ""

# ============================================================================
# 7. Login as Admin User
# ============================================================================
echo "7. Logging in as admin user..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePassword123!"
  }')

SESSION_KEY=$(echo $LOGIN_RESPONSE | jq -r '.key')
if [ "$SESSION_KEY" = "null" ] || [ -z "$SESSION_KEY" ]; then
  echo "   ✗ Failed to login. Response: $LOGIN_RESPONSE"
  exit 1
fi
echo "   ✓ Session key obtained: ${SESSION_KEY}"
echo ""

# ============================================================================
# 8. Create API Key for Admin User
# ============================================================================
echo "8. Creating API key for admin user..."
KEY_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/me/keys" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SESSION_KEY}" \
  -d '{
    "name": "Admin API Key",
    "expires": null
  }')

API_KEY=$(echo $KEY_RESPONSE | jq -r '.key')
if [ "$API_KEY" = "null" ] || [ -z "$API_KEY" ]; then
  echo "   ✗ Failed to create API key. Response: $KEY_RESPONSE"
  exit 1
fi
echo "   ✓ API key created: ${API_KEY}"
echo ""

# ============================================================================
# 9. Verify API Key Can Access Models
# ============================================================================
echo "9. Verifying API key can access models..."
MODELS_RESPONSE=$(curl -s -H "Authorization: Bearer ${API_KEY}" \
  "${BASE_URL}/v1/models")

MODEL_COUNT=$(echo $MODELS_RESPONSE | jq '.data | length')
echo "   ✓ API key can see ${MODEL_COUNT} model(s)"

if [ "$MODEL_COUNT" -eq "0" ]; then
  echo "   ⚠ WARNING: User API key cannot see any models!"
  echo "   This usually means:"
  echo "      - No routers exist, or"
  echo "      - Role limits are not properly set, or"
  echo "      - Routers have no providers"
else
  echo "$MODELS_RESPONSE" | jq -r '.data[] | "      - \(.id)"'
fi
echo ""

# ============================================================================
# 10. Summary
# ============================================================================
echo "=== Bootstrap Complete ==="
echo ""
echo "Credentials:"
echo "   Email:       admin@example.com"
echo "   Password:    SecurePassword123!"
echo "   User ID:     ${USER_ID}"
echo "   Role ID:     ${ROLE_ID}"
echo "   Session Key: ${SESSION_KEY}"
echo "   API Key:     ${API_KEY}"
echo ""
echo "Statistics:"
echo "   Routers:     ${ROUTER_COUNT}"
echo "   Providers:   ${PROVIDER_COUNT}"
echo "   Accessible Models: ${MODEL_COUNT}"
echo ""

if [ "$MODEL_COUNT" -eq "0" ]; then
  echo "⚠ ACTION REQUIRED:"
  echo "   The user API key cannot access any models."
  echo "   Please ensure routers and providers are properly configured."
  echo "   Then re-run this script or manually update the role limits."
  echo ""
fi
