#!/bin/bash
# Upgrade example contract using rotated key

# Exit if any command fails
set -e

echo "🚀 Upgrading contract using rotated key (test-profile-2)..."

# Check if object address file exists
if [ ! -f "./addresses/hello_world_object_address.txt" ]; then
    echo "❌ Object address file not found. Run script 1 first."
    exit 1
fi

# Get the object address
OBJECT_ADDRESS=$(cat ./addresses/hello_world_object_address.txt)
if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Invalid object address"
    exit 1
fi

# Upgrade deployed contract
echo "📦 Upgrading contract..."
UPGRADE_RESULT=$(aptos move upgrade-object \
    --address-name hello_blockchain \
    --object-address $OBJECT_ADDRESS \
    --profile test-profile-2 \
    --assume-yes 2>&1) || {
    echo "❌ Upgrade failed: ${UPGRADE_RESULT}"
    exit 1
}

echo "✅ Contract upgraded successfully using rotated key"
echo "📝 Object address: $OBJECT_ADDRESS"