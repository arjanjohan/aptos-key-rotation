#!/bin/bash
# Deploy example contract

# Exit if any command fails
set -e

# Make deployment directory
mkdir -p ./deployment

echo "🚀 Publishing contract from test-profile-1 (0xaaa)..."

# Compile the contract
echo "📝 Compiling Move modules..."
COMPILE_RESULT=$(aptos move compile --named-addresses hello_blockchain=test-profile-1 2>&1) || {
    echo "❌ Compilation failed: ${COMPILE_RESULT}"
    exit 1
}

# Publish to network
echo "📦 Publishing to network..."
DEPLOY_RESULT=$(aptos move deploy-object \
    --address-name hello_blockchain \
    --profile test-profile-1 \
    --assume-yes 2>&1)

# Extract object address
OBJECT_ADDRESS=$(echo "$DEPLOY_RESULT" | grep -o "0x[a-fA-F0-9]\+" | tail -n 1)

if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Failed to extract object address: ${DEPLOY_RESULT}"
    exit 1
fi

echo "$OBJECT_ADDRESS" > ./addresses/hello_world_object_address.txt
echo "✅ Contract published successfully at object address: $OBJECT_ADDRESS"