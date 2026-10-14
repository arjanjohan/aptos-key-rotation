#!/bin/bash
# Demonstrate invalid key rotation: new key is the same as the current key

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

if ! echo "$ERROR_OUTPUT" | grep -q "New public key cannot be the same as the current public key"; then
    echo "❌ Expected same-key error but got: $ERROR_OUTPUT"
    exit 1
fi

echo "✅ Error received as expected: $ERROR_OUTPUT"
