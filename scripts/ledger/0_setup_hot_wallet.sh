#!/bin/bash
# Setup hot wallet signer for later rotation to Ledger

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

# Make required directories
echo "📁 Creating required directories..."
mkdir -p ./addresses
mkdir -p ./keys

# Create hot wallet and extract address directly from the output
echo "🔑 Generating hot wallet key with vanity prefix 0xaaa..."
GENERATE_RESULT=$(aptos key generate \
    --assume-yes \
    --output-file ./keys/private-key-a \
    --vanity-prefix 0xaaa) || {
    echo "❌ Key generation failed: ${GENERATE_RESULT}"
    exit 1
}

# Extract the account address from the key generation output
ADDRESS_A=$(echo "$GENERATE_RESULT" | grep -o '"Account Address:": "[^"]*"' | cut -d'"' -f4)
echo "$ADDRESS_A" > ./addresses/address_a

echo "🔍 Looking up address for generated key..."
aptos account lookup-address \
    --public-key-file ./keys/private-key-a.pub \
    --url $FULLNODE_URL
echo "ℹ️ The key has no OriginatingAddress entry yet, so the lookup returns the address derived from the key"

# Initialize aptos with the private key
echo "🚀 Initializing Aptos CLI with generated key..."
aptos init \
    --assume-yes \
    --network $NETWORK \
    --private-key-file ./keys/private-key-a \
    --profile ledger-rotation-hot # TODO: change to a more descriptive name

echo "📝 Hot wallet address: $ADDRESS_A"
echo "🔐 Retrieving authentication key..."
AUTH_KEY_RESULT=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::get_authentication_key \
    --url $FULLNODE_URL) || {
    echo "❌ Failed to retrieve authentication key: ${AUTH_KEY_RESULT}"
    exit 1
}
AUTH_KEY=$(echo "$AUTH_KEY_RESULT" | jq -r '.Result[0]')
echo "🔑 Authentication key: $AUTH_KEY"

echo "✅ Hot wallet setup completed successfully!"
echo "ℹ️ This account will later be rotated to use a Ledger hardware wallet"