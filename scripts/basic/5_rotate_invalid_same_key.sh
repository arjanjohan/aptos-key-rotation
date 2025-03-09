#!/bin/bash
# Setup hot wallet signer

# Exit if any command fails
set -e

echo "⚠️ Attempting invalid key rotation (using same key)..."
echo "📝 This operation is expected to fail because the new key is the same as the current key"

# Capture the error output but allow the command to fail
ERROR_OUTPUT=$(aptos account rotate-key \
    --assume-yes \
    --new-private-key-file ./keys/private-key-b \
    --profile test-profile-2 \
    --skip-saving-profile 2>&1 || true)

echo "❌ Error received as expected: "$ERROR_OUTPUT