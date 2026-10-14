#!/bin/bash
# Rotate from Ledger back to a hot wallet (useful for large transactions)

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

# Get the account address
ADDRESS_A=$(cat ./addresses/address_a)
echo "📝 Using address: $ADDRESS_A"

# Create a new hot wallet key
echo "🔑 Generating new hot wallet key with vanity prefix 0xbbb..."
GENERATE_RESULT=$(aptos key generate \
    --assume-yes \
    --output-file ./keys/private-key-b \
    --vanity-prefix 0xbbb) || {
    echo "❌ Key generation failed: ${GENERATE_RESULT}"
    exit 1
}

# Extract the new account address (not used, just for information)
NEW_ADDRESS=$(echo "$GENERATE_RESULT" | grep -o '"Account Address:": "[^"]*"' | cut -d'"' -f4)
echo "📝 New key address (not used): $NEW_ADDRESS"

# Check if Ledger is connected
echo "🔍 Checking for Ledger device..."
echo "⚠️ Please make sure your Ledger device is:"
echo "  1. Connected to your computer"
echo "  2. Unlocked"
echo "  3. Aptos app is open"
echo "  4. Blind signing is enabled in the Aptos app settings"
echo ""
read -p "Press Enter when your Ledger is ready..."

# Rotate the authentication key from Ledger to the new hot wallet
echo "🔄 Rotating authentication key from Ledger to new hot wallet..."
echo "⚠️ You will need to approve the rotation proof challenge signature on your Ledger device"
echo "⚠️ You will then need to approve the transaction on your Ledger device"

ROTATE_RESULT=$(aptos account rotate-key \
    --assume-yes \
    --new-private-key-file ./keys/private-key-b \
    --profile ledger-rotation-ledger \
    --save-to-profile ledger-rotation-temp-hot 2>&1) || {
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
LEDGER_PROFILE=$(aptos config show-profiles --profile ledger-rotation-ledger) || {
    echo "❌ Failed to show profile: ${LEDGER_PROFILE}"
    exit 1
}
HOT_PROFILE=$(aptos config show-profiles --profile ledger-rotation-temp-hot) || {
    echo "❌ Failed to show profile: ${HOT_PROFILE}"
    exit 1
}

LEDGER_PUBLIC_KEY=$(echo "$LEDGER_PROFILE" | grep -o '"public_key": "[^"]*"' | cut -d'"' -f4)
HOT_PUBLIC_KEY=$(echo "$HOT_PROFILE" | grep -o '"public_key": "[^"]*"' | cut -d'"' -f4)
LEDGER_ACCOUNT=$(echo "$LEDGER_PROFILE" | grep -o '"account": "[^"]*"' | cut -d'"' -f4)
HOT_ACCOUNT=$(echo "$HOT_PROFILE" | grep -o '"account": "[^"]*"' | cut -d'"' -f4)

echo "📝 Ledger profile:"
echo "  - Public key: $LEDGER_PUBLIC_KEY"
echo "  - Account: $LEDGER_ACCOUNT"
echo "📝 New hot wallet profile:"
echo "  - Public key: $HOT_PUBLIC_KEY"
echo "  - Account: $HOT_ACCOUNT"

if [ "$LEDGER_ACCOUNT" != "$HOT_ACCOUNT" ]; then
    echo "❌ Account addresses don't match after rotation"
    exit 1
fi

if [ "$LEDGER_PUBLIC_KEY" == "$HOT_PUBLIC_KEY" ]; then
    echo "❌ Public keys are the same after rotation"
    exit 1
fi

# Rename the Ledger profile to indicate it's stale
echo "📝 Renaming Ledger profile to indicate it's stale..."
aptos config rename-profile \
    --profile ledger-rotation-ledger \
    --new-profile-name ledger-rotation-ledger-stale

echo "✅ Key rotation to hot wallet completed successfully!"
echo "📝 Account address: $HOT_ACCOUNT"
echo "📝 New profile: ledger-rotation-temp-hot"
echo "ℹ️ The account is now secured by the new hot wallet key"
echo "ℹ️ This is useful for operations that exceed Ledger memory limitations"
echo "ℹ️ The Ledger profile has been renamed to ledger-rotation-ledger-stale"