#!/bin/bash

MOUNTPOINT="/localdisk"
TESTFILE="$MOUNTPOINT/testfile"


echo "📊 Starting 100 GB benchmark on $MOUNTPOINT..."

# Write test
echo "📝 Sequential write test (100 GB) .............................."
sudo dd if=/dev/zero of="$TESTFILE" bs=1G count=100 oflag=direct status=progress

# Read test
echo "📖 Sequential read test (100 GB) .............................."
sudo dd if="$TESTFILE" of=/dev/null bs=1G count=100 iflag=direct status=progress

# Clean up
echo "🧹 Removing test file..."
sudo rm -f "$TESTFILE"

echo "✅ 100 GB benchmark complete."
