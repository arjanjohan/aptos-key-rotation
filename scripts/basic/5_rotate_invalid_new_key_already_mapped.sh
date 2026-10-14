#!/bin/bash
# Demonstrate invalid key rotation: new key is already mapped in the OriginatingAddress table

# Exit if any command fails
set -e

# Load configuration
source "$(dirname "$0")/../config.sh"
echo "🌐 Using network: $NETWORK with URL: $FULLNODE_URL"

echo "🔑 Generating third hot wallet key with vanity prefix 0xccc..."
GENERATE_RESULT=$(aptos key generate \
    --assume-yes \
    --output-file ./keys/private-key-c \
    --vanity-prefix 0xccc) || {
    echo "❌ Key generation failed: ${GENERATE_RESULT}"
    exit 1
}

# Extract the account address from the key generation output
ADDRESS_C=$(echo "$GENERATE_RESULT" | grep -o '"Account Address:": "[^"]*"' | cut -d'"' -f4)
echo "📝 Generated key with address: $ADDRESS_C"

echo "🚀 Initializing new profile with generated key..."
INIT_RESULT=$(aptos init \
    --assume-yes \
    --network $NETWORK \
    --private-key-file ./keys/private-key-c \
    --profile test-profile-3) || {
    echo "❌ Profile initialization failed: ${INIT_RESULT}"
    exit 1
}

echo "✅ Initialized profile test-profile-3 successfully"

echo "⚠️ Attempting invalid key rotation (key already mapped in OriginatingAddress table)..."
echo "📝 This operation is expected to fail because the authentication key is already mapped (ENEW_AUTH_KEY_ALREADY_MAPPED)"

# Capture the error output but allow the command to fail
ERROR_OUTPUT=$(aptos account rotate-key \
    --assume-yes \
    --max-gas 100000 \
    --new-private-key-file ./keys/private-key-b \
    --profile test-profile-3 \
    --skip-saving-profile 2>&1 || true)

if ! echo "$ERROR_OUTPUT" | grep -q "ENEW_AUTH_KEY_ALREADY_MAPPED"; then
    echo "❌ Expected ENEW_AUTH_KEY_ALREADY_MAPPED but got: $ERROR_OUTPUT"
    exit 1
fi

echo "✅ Error received as expected: $ERROR_OUTPUT"
