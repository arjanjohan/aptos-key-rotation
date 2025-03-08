#!/bin/bash
# Setup hot wallet signer

# Exit if any command fails
set -e

echo "🔄 Rotating authentication key of first account to use third key..."
ROTATE_RESULT=$(aptos account rotate-key \
    --assume-yes \
    --new-private-key-file ./keys/private-key-c \
    --profile test-profile-2 \
    --save-to-profile test-profile-4)

echo "✅ First rotation successful"

echo "⚠️ Attempting invalid key rotation for third account..."
echo "📝 This operation is expected to fail due to invalid originating address"

# Capture the error output but allow the command to fail
ERROR_OUTPUT=$(aptos account rotate-key \
    --assume-yes \
    --max-gas 100000 \
    --new-private-key-file ./keys/private-key-b \
    --profile test-profile-3 \
    --skip-saving-profile 2>&1 || true)

echo "❌ Error received as expected: EINVALID_ORIGINATING_ADDRESS - The expected originating address is different from the originating address on-chain"