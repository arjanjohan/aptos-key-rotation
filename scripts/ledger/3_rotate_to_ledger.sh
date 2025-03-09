#!/bin/bash
# Rotate hot wallet key to Ledger hardware wallet

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

# Get the account address
ADDRESS_A=$(cat ./addresses/address_a)
echo "📝 Using address: $ADDRESS_A"

# Check if Ledger is connected
echo "🔍 Checking for Ledger device..."
echo "⚠️ Please make sure your Ledger device is:"
echo "  1. Connected to your computer"
echo "  2. Unlocked"
echo "  3. Aptos app is open"
echo "  4. Blind signing is enabled in the Aptos app settings"
echo ""
read -p "Press Enter when your Ledger is ready..."

# Define the derivation index for Ledger (using 1000 as recommended best practice)
echo "🔑 Using BIP44 derivation index: $DERIVATION_INDEX"

# Rotate the authentication key to Ledger
echo "🔄 Rotating authentication key to Ledger..."
echo "⚠️ You will need to approve the rotation proof challenge signature on your Ledger device"

ROTATE_RESULT=$(aptos account rotate-key \
    --assume-yes \
    --new-derivation-index $DERIVATION_INDEX \
    --profile ledger-rotation-hot \
    --save-to-profile ledger-rotation-ledger 2>&1) || {
    echo "❌ Key rotation failed. Please check that your Ledger is connected, unlocked, and the Aptos app is open."
    echo "Error: $ROTATE_RESULT"
    exit 1
}

# Extract transaction hash
TX_HASH=$(echo "$ROTATE_RESULT" | grep -o '"transaction_hash": "[^"]*"' | head -1 | cut -d'"' -f4)
if [ -z "$TX_HASH" ]; then
    echo "❌ Failed to extract transaction hash from rotation result"
    exit 1
fi

echo "🔍 Key rotation transaction hash: $TX_HASH"

# Compare profiles to verify rotation
echo "📊 Comparing profiles to verify rotation..."
HOT_PROFILE=$(aptos config show-profiles --profile ledger-rotation-hot)
LEDGER_PROFILE=$(aptos config show-profiles --profile ledger-rotation-ledger)

HOT_PUBLIC_KEY=$(echo "$HOT_PROFILE" | grep -o '"public_key": "[^"]*"' | cut -d'"' -f4)
LEDGER_PUBLIC_KEY=$(echo "$LEDGER_PROFILE" | grep -o '"public_key": "[^"]*"' | cut -d'"' -f4)
HOT_ACCOUNT=$(echo "$HOT_PROFILE" | grep -o '"account": "[^"]*"' | cut -d'"' -f4)
LEDGER_ACCOUNT=$(echo "$LEDGER_PROFILE" | grep -o '"account": "[^"]*"' | cut -d'"' -f4)

echo "📝 Hot wallet profile:"
echo "  - Public key: $HOT_PUBLIC_KEY"
echo "  - Account: $HOT_ACCOUNT"
echo "📝 Ledger profile:"
echo "  - Public key: $LEDGER_PUBLIC_KEY"
echo "  - Account: $LEDGER_ACCOUNT"

if [ "$HOT_ACCOUNT" != "$LEDGER_ACCOUNT" ]; then
    echo "❌ Account addresses don't match after rotation"
    exit 1
fi

if [ "$HOT_PUBLIC_KEY" == "$LEDGER_PUBLIC_KEY" ]; then
    echo "❌ Public keys are the same after rotation"
    exit 1
fi

echo "✅ Key rotation to Ledger completed successfully!"
echo "📝 Account address: $LEDGER_ACCOUNT"
echo "📝 New profile: ledger-rotation-ledger"
echo "ℹ️ The account is now secured by your Ledger hardware wallet"
echo "ℹ️ The hot wallet profile (ledger-rotation-hot) is now stale and should not be used"