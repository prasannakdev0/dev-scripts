#!/bin/bash
set -e

RAID_DEVICE="/dev/md0"
MOUNTPOINT="/localdisk"

echo "🔎 Looking for RAID device $RAID_DEVICE..."

# Check if RAID exists
if ! sudo mdadm --detail "$RAID_DEVICE" &>/dev/null; then
    echo "❌ RAID device $RAID_DEVICE not found. Skipping teardown."
    echo "🔍 You may still want to manually clean /etc/fstab if stale entries exist:"
    echo "     sudo sed -i '\\|/localdisk|d' /etc/fstab"
    exit 0
fi

# Extract member devices
DEVICES=($(sudo mdadm --detail "$RAID_DEVICE" | awk '/dev\/[a-z]/ {print $NF}' | sort -u))
echo "📦 Found ${#DEVICES[@]} member devices:"
printf ' - %s\n' "${DEVICES[@]}"

# Unmount if needed
if mountpoint -q "$MOUNTPOINT"; then
    echo "⏏️ Unmounting $MOUNTPOINT..."
    sudo umount "$MOUNTPOINT"
fi

# Stop and remove RAID
echo "🛑 Stopping and removing RAID device $RAID_DEVICE..."
sudo mdadm --stop "$RAID_DEVICE" || true
sudo mdadm --remove "$RAID_DEVICE" || true

# Wipe metadata
echo "🧽 Wiping RAID metadata from member disks..."
for dev in "${DEVICES[@]}"; do
    echo "   ➤ Cleaning $dev"
    sudo wipefs -a "$dev" || true
    sudo mdadm --zero-superblock --force "$dev" || true
done

# Clean mdadm config
echo "🧹 Cleaning up /etc/mdadm/mdadm.conf..."
sudo sed -i '/ARRAY \/dev\/md0/d' /etc/mdadm/mdadm.conf

# Update initramfs
echo "🔄 Updating initramfs..."
sudo update-initramfs -u

# Clean fstab
echo "🧹 Removing all /localdisk entries from /etc/fstab..."
sudo sed -i '\|/localdisk|d' /etc/fstab

# Remove mount dir if empty
if [ -d "$MOUNTPOINT" ] && [ -z "$(ls -A "$MOUNTPOINT")" ]; then
    echo "🗑️ Removing empty mount directory $MOUNTPOINT..."
    sudo rmdir "$MOUNTPOINT"
fi

# Done
echo "✅ RAID 0 at $RAID_DEVICE has been fully dismantled."
echo "📁 Mount point $MOUNTPOINT is cleaned up."
echo "📜 /etc/fstab and mdadm config are now clean."
