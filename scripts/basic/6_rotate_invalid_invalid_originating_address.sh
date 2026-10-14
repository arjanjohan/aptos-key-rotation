#!/bin/bash
# Demonstrate invalid key rotation: current key is mapped to a different originating address

# Exit if any command fails
set -e

echo "🔄 Rotating authentication key of first account to use third key..."
ROTATE_RESULT=$(aptos account rotate-key \
    --assume-yes \
    --new-private-key-file ./keys/private-key-c \
    --profile test-profile-2 \
    --save-to-profile test-profile-4) || {
    echo "❌ Key rotation failed: ${ROTATE_RESULT}"
    exit 1
}

echo "✅ First rotation successful"

echo "⚠️ Attempting invalid key rotation for third account..."
echo "📝 This operation is expected to fail due to invalid originating address (EINVALID_ORIGINATING_ADDRESS)"

# Capture the error output but allow the command to fail
ERROR_OUTPUT=$(aptos account rotate-key \
    --assume-yes \
    --max-gas 100000 \
    --new-private-key-file ./keys/private-key-b \
    --profile test-profile-3 \
    --skip-saving-profile 2>&1 || true)

if ! echo "$ERROR_OUTPUT" | grep -q "EINVALID_ORIGINATING_ADDRESS"; then
    echo "❌ Expected EINVALID_ORIGINATING_ADDRESS but got: $ERROR_OUTPUT"
    exit 1
fi

echo "✅ Error received as expected: $ERROR_OUTPUT"
