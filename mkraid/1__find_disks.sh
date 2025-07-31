#!/bin/bash

OUTFILE="__raid_disks.txt"
TARGET_GIB=375
TARGET_SIZE=$((TARGET_GIB * 1024 * 1024 * 1024))  # 402,653,184,000 bytes

echo "🔍 Looking for truly unused, unmounted NVMe SSDs of size $TARGET_GIB GiB ($TARGET_SIZE bytes)..."

# Clear output file
> "$OUTFILE"

# Get candidate NVMe disks matching exact size
for dev in $(lsblk -b -dn -o NAME,SIZE | awk -v size="$TARGET_SIZE" '$2 == size {print $1}'); do
    full_path="/dev/$dev"
    
    # Check for no partitions
    if lsblk -n "$full_path" | awk 'NR>1 {exit 1}'; then
        # Check if it's used in any mdadm RAID
        if ! grep -q "$dev" /proc/mdstat; then
            # Check mount status (should not be mounted or have children mounted)
            if [ -z "$(lsblk -n -o MOUNTPOINT "$full_path" | grep -v '^$')" ]; then
                echo "$full_path" >> "$OUTFILE"
            fi
        fi
    fi
done

# Output result
if [ -s "$OUTFILE" ]; then
    echo "✅ Found $(wc -l < "$OUTFILE") unused unmounted disks matching $TARGET_GIB GiB:"
    cat "$OUTFILE"
else
    echo "❌ No clean unmounted disks of $TARGET_GIB GiB found."
    echo "💡 Tip: Manually verify with 'lsblk -b -dn -o NAME,SIZE' and 'cat /proc/mdstat'."
    exit 1
fi
