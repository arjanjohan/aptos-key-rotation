#!/bin/bash
# Clean up all profiles and files from ledger rotation demo

# Exit if any command fails
set -e

echo "🧹 Cleaning up all profiles and files from ledger rotation demo..."

# List of profiles to delete
PROFILES=(
    "ledger-rotation-hot"
    "ledger-rotation-ledger-stale"
    "ledger-rotation-temp-hot"
    "ledger-rotation-ledger-final"
)

# Delete profiles
for PROFILE in "${PROFILES[@]}"; do
    echo "🗑️ Deleting profile: $PROFILE"
    aptos config delete-profile --profile "$PROFILE" 2>/dev/null || echo "  ℹ️ Profile $PROFILE not found or already deleted"
done

# Delete all private keys
echo "🗑️ Deleting all private keys..."
rm -f ./keys/private-key-a 2>/dev/null || echo "  ℹ️ private-key-a not found or already deleted"
rm -f ./keys/private-key-a.pub 2>/dev/null || echo "  ℹ️ private-key-a.pub not found or already deleted"
rm -f ./keys/private-key-b 2>/dev/null || echo "  ℹ️ private-key-b not found or already deleted"
rm -f ./keys/private-key-b.pub 2>/dev/null || echo "  ℹ️ private-key-b.pub not found or already deleted"

# Delete all address files
echo "🗑️ Deleting all address files..."
rm -f ./addresses/address_a 2>/dev/null || echo "  ℹ️ address_a not found or already deleted"
rm -f ./addresses/deployed_object.txt 2>/dev/null || echo "  ℹ️ deployed_object.txt not found or already deleted"

# Remove directories if empty
echo "🗑️ Removing empty directories..."
rmdir ./keys 2>/dev/null || echo "  ℹ️ keys directory not empty or already deleted"
rmdir ./addresses 2>/dev/null || echo "  ℹ️ addresses directory not empty or already deleted"

echo "✅ Complete cleanup successful!"
echo "ℹ️ All keys, addresses, and profiles have been deleted"