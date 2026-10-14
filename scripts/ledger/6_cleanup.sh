#!/bin/bash
# Clean up all profiles and files from ledger rotation demo

# Exit if any command fails
set -e

echo "🧹 Cleaning up all profiles and files from ledger rotation demo..."

# List of profiles to delete
# ledger-rotation-ledger only exists if the demo stopped before script 4 renamed it
PROFILES=(
    "ledger-rotation-hot"
    "ledger-rotation-ledger"
    "ledger-rotation-ledger-stale"
    "ledger-rotation-temp-hot"
)

# Delete profiles
for PROFILE in "${PROFILES[@]}"; do
    echo "🗑️ Deleting profile: $PROFILE"
    aptos config delete-profile --profile "$PROFILE" >/dev/null 2>&1 || echo "  ℹ️ Profile $PROFILE not found or already deleted"
done

echo "🗑️ Removing directories and files..."
rm -rf ./addresses
echo "✓ Removed addresses directory"

rm -rf ./keys
echo "✓ Removed keys directory"

echo "✅ Complete cleanup successful!"
echo "ℹ️ All keys, addresses, and profiles have been deleted"
