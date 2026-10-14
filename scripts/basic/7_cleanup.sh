#!/bin/bash
# Cleanup script to remove test profiles and files

echo "🧹 Cleaning up test environment..."

PROFILES=(
    "test-profile-1"
    "test-profile-2"
    "test-profile-3"
    "test-profile-4"
)

echo "🗑️ Deleting test profiles..."
for PROFILE in "${PROFILES[@]}"; do
    if aptos config delete-profile --profile "$PROFILE" >/dev/null 2>&1; then
        echo "✓ Deleted $PROFILE"
    else
        echo "  ℹ️ Profile $PROFILE not found or already deleted"
    fi
done

echo "🗑️ Removing directories and files..."
rm -rf ./addresses
echo "✓ Removed addresses directory"

rm -rf ./keys
echo "✓ Removed keys directory"

echo "✅ Cleanup completed successfully!"
