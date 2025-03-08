#!/bin/bash
# Setup hot wallet signer

# Exit if any command fails
set -e

# Create second hot wallet
echo "🔑 Generating second hot wallet key with vanity prefix 0xbbb..."
GENERATE_RESULT=$(aptos key generate \
    --assume-yes \
    --output-file ./keys/private-key-b \
    --vanity-prefix 0xbbb)

# Extract the account address from the key generation output
ADDRESS_B_INITIAL=$(echo "$GENERATE_RESULT" | grep -o '"Account Address:": "[^"]*"' | cut -d'"' -f4)
echo "📝 Generated key with address: $ADDRESS_B_INITIAL"

echo "🔄 Rotating authentication key to new private key..."
ROTATE_RESULT=$(aptos account rotate-key \
    --assume-yes \
    --new-private-key-file ./keys/private-key-b \
    --profile test-profile-1 \
    --save-to-profile test-profile-2)

echo "✅ Authentication key rotated successfully"

echo "📋 Showing profile configurations..."
echo "📝 Original profile (test-profile-1):"
PROFILE1=$(aptos config show-profiles --profile test-profile-1)
ACCOUNT1=$(echo "$PROFILE1" | jq -r '.Result."test-profile-1".account')
echo "Account: $ACCOUNT1"

echo "📝 New profile after rotation (test-profile-2):"
PROFILE2=$(aptos config show-profiles --profile test-profile-2)
ACCOUNT2=$(echo "$PROFILE2" | jq -r '.Result."test-profile-2".account')
echo "Account: $ACCOUNT2"

export ADDRESS_A=$(cat ./addresses/address_a)
echo "📝 Using address: $ADDRESS_A"

echo "🔍 Retrieving new authentication key..."
AUTH_KEY_RESULT=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::get_authentication_key \
    --url https://fullnode.devnet.aptoslabs.com)

AUTH_KEY=$(echo "$AUTH_KEY_RESULT" | jq -r '.Result[0]')
echo "$AUTH_KEY" > ./addresses/address_b
echo "📝 New authentication key: $AUTH_KEY"

echo "🔍 Checking originating address for original authentication key..."
ORIG_ADDRESS_A_RESULT=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::originating_address \
    --url https://fullnode.devnet.aptoslabs.com)

echo "🔍 Checking originating address for new authentication key..."
ORIG_ADDRESS_B_RESULT=$(aptos move view \
    --args address:$AUTH_KEY \
    --function-id 0x1::account::originating_address \
    --url https://fullnode.devnet.aptoslabs.com)

ORIG_ADDRESS_B=$(echo "$ORIG_ADDRESS_B_RESULT" | jq -r '.Result[0].vec[0]')
if [ -n "$ORIG_ADDRESS_B" ] && [ "$ORIG_ADDRESS_B" != "null" ]; then
    echo "📝 Originating address for new key: $ORIG_ADDRESS_B"
fi

echo "✅ Authentication key rotation completed successfully!"