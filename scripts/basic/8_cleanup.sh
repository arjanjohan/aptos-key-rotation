#!/bin/bash
# Cleanup script to remove test profiles and files

echo "🧹 Cleaning up test environment..."

echo "🗑️ Deleting test profiles..."
DELETE_RESULT1=$(aptos config delete-profile --profile test-profile-1)
echo "✓ Deleted test-profile-1"

DELETE_RESULT2=$(aptos config delete-profile --profile test-profile-2)
echo "✓ Deleted test-profile-2"

DELETE_RESULT3=$(aptos config delete-profile --profile test-profile-3)
echo "✓ Deleted test-profile-3"

DELETE_RESULT4=$(aptos config delete-profile --profile test-profile-4)
echo "✓ Deleted test-profile-4"

echo "🗑️ Removing directories and files..."
rm -rf ./addresses
echo "✓ Removed addresses directory"

rm -rf ./keys
echo "✓ Removed keys directory"

echo "✅ Cleanup completed successfully!"