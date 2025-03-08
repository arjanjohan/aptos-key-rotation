#!/bin/bash
# Setup hot wallet signer

# Exit if any command fails
set -e

export ADDRESS_A=$(cat ./addresses/address_a)
echo "📝 Using address: $ADDRESS_A"

echo "🔍 Checking current originating address..."
ORIG_ADDRESS_BEFORE=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::originating_address \
    --url https://fullnode.devnet.aptoslabs.com)

EMPTY_VEC=$(echo "$ORIG_ADDRESS_BEFORE" | jq -r '.Result[0].vec | length')
if [ "$EMPTY_VEC" -ne 0 ]; then
    ORIG_VEC=$(echo "$ORIG_ADDRESS_BEFORE" | jq -r '.Result[0].vec')
    echo "❌ Expected empty originating address but got:"
    echo "$ORIG_VEC"
    exit 1
fi

echo "📝 Verified originating address is empty (vec length: $EMPTY_VEC)"
echo "ℹ️ Initial originating address check complete"

echo "✍️ Setting originating address..."
SET_RESULT=$(aptos move run \
    --assume-yes \
    --function-id 0x1::account::set_originating_address \
    --profile test-profile-1)

echo "✅ Originating address set successfully"

echo "🔍 Verifying updated originating address..."
ORIG_ADDRESS_AFTER=$(aptos move view \
    --args address:$ADDRESS_A \
    --function-id 0x1::account::originating_address \
    --url https://fullnode.devnet.aptoslabs.com)

AUTH_KEY=$(echo "$ORIG_ADDRESS_AFTER" | jq -r '.Result[0].vec[0]')
if [ -n "$AUTH_KEY" ] && [ "$AUTH_KEY" != "null" ]; then
    echo "📝 Originating address now set to: $AUTH_KEY"
fi

echo "✅ Originating address setup completed successfully!"