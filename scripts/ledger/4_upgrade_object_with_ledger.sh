#!/bin/bash
# Upgrade example contract using Ledger after key rotation

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

# Check if object address file exists
if [ ! -f "./addresses/deployed_object.txt" ]; then
    echo "❌ Object address file not found. Run script 2 first."
    exit 1
fi

# Get the object address
OBJECT_ADDRESS=$(cat ./addresses/deployed_object.txt)
if [ -z "$OBJECT_ADDRESS" ]; then
    echo "❌ Invalid object address"
    exit 1
fi

# Check if Ledger is connected
echo "🔍 Checking for Ledger device..."
echo "⚠️ Please make sure your Ledger device is:"
echo "  1. Connected to your computer"
echo "  2. Unlocked"
echo "  3. Aptos app is open"
echo "  4. Blind signing is enabled in the Aptos app settings"
echo ""
read -p "Press Enter when your Ledger is ready..."

# Compile the contract
echo "📝 Compiling Move modules..."
COMPILE_RESULT=$(aptos move compile --named-addresses hello_blockchain=ledger-rotation-ledger 2>&1) || {
    echo "❌ Compilation failed: ${COMPILE_RESULT}"
    exit 1
}

# Upgrade deployed contract using Ledger
echo "📦 Upgrading contract using Ledger..."
echo "⚠️ You will need to approve the transaction on your Ledger device"

echo "📦 Upgrading contract..."
UPGRADE_RESULT=$(aptos move upgrade-object \
    --address-name hello_blockchain \
    --object-address $OBJECT_ADDRESS \
    --profile ledger-rotation-ledger \
    --assume-yes 2>&1) || {
    echo "❌ Upgrade failed: ${UPGRADE_RESULT}"
    exit 1
}

echo "✅ Contract upgraded successfully using Ledger!"
echo "📝 Object address: $OBJECT_ADDRESS"
echo "ℹ️ This confirms that the Ledger-secured account maintains the same permissions as the original hot wallet"