#!/bin/bash
# Upgrade example contract using temporary hot wallet

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

# Check if object address file exists
if [ ! -f "./addresses/deployed_object.txt" ]; then
    echo "❌ Object address file not found. Run script 1 first."
    exit 1
fi

# Get the object address
OBJECT_ADDRESS=$(cat ./addresses/deployed_object.txt)
if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Invalid object address"
    exit 1
fi

# Upgrade deployed contract using temporary hot wallet
echo "📦 Upgrading contract using temporary hot wallet..."

UPGRADE_RESULT=$(aptos move upgrade-object \
    --address-name hello_blockchain \
    --object-address $OBJECT_ADDRESS \
    --profile ledger-rotation-temp-hot \
    --assume-yes 2>&1) || {
    echo "❌ Upgrade failed: ${UPGRADE_RESULT}"
    exit 1
}

echo "✅ Contract upgraded successfully using temporary hot wallet!"
echo "📝 Object address: $OBJECT_ADDRESS"
echo "ℹ️ This confirms that the temporary hot wallet maintains the same permissions"
echo "ℹ️ This approach is useful for operations that exceed Ledger memory limitations"