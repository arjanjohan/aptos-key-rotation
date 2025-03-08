#!/bin/bash
# Setup hot wallet signer

# Exit if any command fails
set -e

# Make required directories
echo "📁 Creating required directories..."
mkdir -p ./addresses
mkdir -p ./keys

# Create hot wallet and extract address directly from the output
echo "🔑 Generating hot wallet key with vanity prefix 0xaaa..."
GENERATE_RESULT=$(aptos key generate \
    --assume-yes \
    --output-file ./keys/private-key-a \
    --vanity-prefix 0xaaa)

# Extract the account address from the key generation output
ADDRESS_A=$(echo "$GENERATE_RESULT" | grep -o '"Account Address:": "[^"]*"' | cut -d'"' -f4)
echo "$ADDRESS_A" > ./addresses/address_a

echo "🔍 Looking up address for generated key..."
aptos account lookup-address \
    --public-key-file ./keys/private-key-a.pub \
    --url https://fullnode.devnet.aptoslabs.com || true
echo "ℹ️ This error is expected since the account doesn't exist on-chain yet"

# Initialize aptos with the private key
echo "🚀 Initializing Aptos CLI with generated key..."
aptos init \
    --assume-yes \
    --network devnet \
    --private-key-file ./keys/private-key-a \
    --profile test-profile-1

echo "📝 Hot wallet address: $ADDRESS_A"
echo "🔐 Retrieving authentication key..."
AUTH_KEY=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::get_authentication_key \
    --url https://fullnode.devnet.aptoslabs.com \
    | jq -r '.Result[0]')
echo "🔑 Authentication key: $AUTH_KEY"

echo "✅ Hot wallet setup completed successfully!"