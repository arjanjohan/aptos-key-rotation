#!/bin/bash
# Deploy example contract using hot wallet

# Exit if any command fails
set -e

echo "🚀 Publishing contract from ledger-rotation-hot..."

# Deploy the contract
echo "📦 Deploying contract..."
DEPLOY_RESULT=$(aptos move deploy-object \
    --address-name hello_blockchain \
    --profile ledger-rotation-hot \
    --assume-yes 2>&1) || {
    echo "❌ Deployment failed: ${DEPLOY_RESULT}"
    exit 1
}

# Extract object address
OBJECT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep -o '"deployed_object_address": "[^"]*"' | cut -d'"' -f4)

if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Failed to extract object address: ${DEPLOY_RESULT}"
    exit 1
fi

OBJECT_ADDRESS="0x$OBJECT_ADDRESS"
echo "$OBJECT_ADDRESS" > ./addresses/deployed_object.txt
echo "✅ Contract published successfully at object address: $OBJECT_ADDRESS"