#!/bin/bash
# Deploy example contract using hot wallet

# Exit if any command fails
set -e

echo "🚀 Publishing contract from ledger-rotation-hot..."

# Compile the contract
echo "📝 Compiling Move modules..."
COMPILE_RESULT=$(aptos move compile --named-addresses hello_blockchain=ledger-rotation-hot 2>&1) || {
    echo "❌ Compilation failed: ${COMPILE_RESULT}"
    exit 1
}

# Deploy the contract
echo "📦 Deploying contract..."
DEPLOY_RESULT=$(aptos move deploy-object \
    --address-name hello_blockchain \
    --profile ledger-rotation-hot \
    --assume-yes 2>&1)

# Extract object address
OBJECT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep -o "0x[a-fA-F0-9]\+" | tail -n 1)

if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Failed to extract object address: ${DEPLOY_RESULT}"
    exit 1
fi

echo "$OBJECT_ADDRESS" > ./addresses/deployed_object.txt
echo "✅ Contract published successfully at object address: $OBJECT_ADDRESS"