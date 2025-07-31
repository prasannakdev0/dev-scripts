#!/bin/bash

# Output file
OUTFILE="__raid_disks.txt"

# Define target disk size: 375 GiB in bytes (binary unit: 1024^3)
TARGET_GIB=375
TARGET_SIZE=$((TARGET_GIB * 1024 * 1024 * 1024))  # 402,653,184,000 bytes

echo "🔍 Looking for unmounted NVMe SSDs of size $TARGET_GIB GiB ($TARGET_SIZE bytes)..."

# Get all unmounted disks of exact size
lsblk -b -dn -o NAME,SIZE,MOUNTPOINT | awk -v size="$TARGET_SIZE" '$2 == size && $3 == "" {print "/dev/" $1}' > "$OUTFILE"

# Output result
if [ -s "$OUTFILE" ]; then
    echo "✅ Found $(wc -l < "$OUTFILE") unmounted disks matching $TARGET_GIB GiB:"
    cat "$OUTFILE"
else
    echo "❌ No unmounted disks of $TARGET_GIB GiB ($TARGET_SIZE bytes) found."
    echo "💡 Tip: Run 'lsblk -b -dn -o NAME,SIZE,MOUNTPOINT' to inspect manually."
    exit 1
fi
