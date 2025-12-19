#!/bin/bash

# OpenGateLLM Bootstrap Script
# This script creates all necessary resources: roles, users, organizations, and providers

set -e  # Exit on error

# Configuration
BASE_URL="http:///<API-EXTERNAL-IP>"
ADMIN_API_KEY="changeme"

echo "=== OpenGateLLM Bootstrap Script ==="
echo "Base URL: ${BASE_URL}"
echo ""

# ============================================================================
# 1. Create Admin Role
# ============================================================================
echo "1. Creating admin role..."
ROLE_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/admin/roles" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  -d '{
    "name": "Admin Role",
    "permissions": ["admin", "create_public_collection", "read_metrics", "provide_models"],
    "limits": []
  }')

ROLE_ID=$(echo $ROLE_RESPONSE | jq -r '.id')
echo "   ✓ Admin role created with ID: ${ROLE_ID}"
echo ""

# ============================================================================
# 2. Add Router Limits to Admin Role
# ============================================================================
echo "2. Adding router access to admin role..."

# Get all routers
ROUTERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/routers")

# Build limits array for all routers (allowing unlimited access)
LIMITS=$(echo $ROUTERS | jq '[.data[] | {router: .id, type: "rpm", value: null}]')

# Update role with router limits
UPDATE_ROLE=$(curl -s -X PATCH "${BASE_URL}/v1/admin/roles/${ROLE_ID}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  -d '{
    "name": "Admin Role",
    "permissions": ["admin", "create_public_collection", "read_metrics", "provide_models"],
    "limits": '"${LIMITS}"'
  }')

echo "   ✓ Added access to $(echo $LIMITS | jq 'length') routers"
echo ""
#
## ============================================================================
## 3. Create Organization (optional)
## ============================================================================
#echo "2. Creating organization..."
#ORG_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/admin/organizations" \
#  -H "Content-Type: application/json" \
#  -H "Authorization: Bearer ${ADMIN_API_KEY}" \
#  -d '{
#    "name": "Default Organization",
#    "budget": null,
#    "expires": null
#  }')
#
#ORG_ID=$(echo $ORG_RESPONSE | jq -r '.id')
#echo "   ✓ Organization created with ID: ${ORG_ID}"
#echo ""

# ============================================================================
# 4. Create Admin User
# ============================================================================
echo "4. Creating admin user..."
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
echo "   ✓ User created with ID: ${USER_ID}"
echo ""

# ============================================================================
# 4. Login as Admin User
# ============================================================================
echo "4. Logging in as admin user..."
LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "SecurePassword123!"
  }')

SESSION_KEY=$(echo $LOGIN_RESPONSE | jq -r '.key')
echo "   ✓ Session key obtained: ${SESSION_KEY}"
echo ""

# ============================================================================
# 5. Create API Key for Admin User
# ============================================================================
echo "5. Creating API key for admin user..."
KEY_RESPONSE=$(curl -s -X POST "${BASE_URL}/v1/me/keys" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SESSION_KEY}" \
  -d '{
    "name": "Admin API Key",
    "expires": null
  }')

API_KEY=$(echo $KEY_RESPONSE | jq -r '.key')
echo "   ✓ API key created: ${API_KEY}"
echo ""

# ============================================================================
# 6. List Existing Routers
# ============================================================================
echo "6. Listing existing routers/models..."
ROUTERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/routers")

echo "$ROUTERS" | jq -r '.data[] | "   - Router ID \(.id): \(.name) (type: \(.type), providers: \(.providers))"'
echo ""

# ============================================================================
# 7. Create Missing Providers
# ============================================================================
echo "7. Creating missing providers..."


ROUTER_3_PROVIDERS=$(echo $ROUTERS | jq -r '.data[] | select(.id == 3) | .providers')


# Provider for Mistral-Small (Router ID 3) if missing
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
  echo "   ✓ Provider created for Mistral-Small with ID: ${PROVIDER_3_ID}"
else
  echo "   ✓ Provider already exists for Mistral-Small (Router ID 3)"
fi

echo ""

# ============================================================================
# 8. Verify All Providers
# ============================================================================
echo "8. Verifying all providers..."
PROVIDERS=$(curl -s -H "Authorization: Bearer ${ADMIN_API_KEY}" \
  "${BASE_URL}/v1/admin/providers")

echo "$PROVIDERS" | jq -r '.data[] | "   - Provider ID \(.id): \(.model_name) -> \(.url) (router_id: \(.router_id))"'
echo ""
