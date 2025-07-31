#!/bin/bash

set -e  # ✅ Exit immediately on any command failure

DEVLIST_FILE="__raid_disks.txt"
MOUNTPOINT="/localdisk"
RAID_DEVICE="/dev/md0"

# ✅ Check if device list file exists and is not empty
if [ ! -s "$DEVLIST_FILE" ]; then
    echo "❌ Device list file '$DEVLIST_FILE' is missing or empty."
    exit 1
fi

# ✅ Read disk list into an array
mapfile -t DEVICES < "$DEVLIST_FILE"

echo "🛠️ Creating RAID 0 array from ${#DEVICES[@]} devices:"
printf ' - %s\n' "${DEVICES[@]}"

sudo apt update
sudo apt install -y mdadm

# ⚠️ Double-check if md0 already exists to avoid accidental overwrite
if [ -e "$RAID_DEVICE" ]; then
    echo "⚠️ RAID device $RAID_DEVICE already exists. Aborting to prevent data loss."
    echo "👉 Use 'sudo mdadm --stop $RAID_DEVICE' and 'sudo wipefs -a $RAID_DEVICE' if you want to recreate."
    exit 1
fi

# ✅ Create RAID 0
sudo mdadm --create --verbose "$RAID_DEVICE" --level=0 --raid-devices=${#DEVICES[@]} "${DEVICES[@]}"

# ⏳ Wait for RAID device to become available
echo "⏳ Waiting for $RAID_DEVICE to be ready..."
sleep 5

# ✅ Format RAID array
echo "📦 Formatting $RAID_DEVICE with ext4..."
sudo mkfs.ext4 -F "$RAID_DEVICE"

# ✅ Mount point setup
echo "📁 Mounting at $MOUNTPOINT..."
sudo mkdir -p "$MOUNTPOINT"
sudo mount "$RAID_DEVICE" "$MOUNTPOINT"

# ✅ Make persistent
echo "💾 Making RAID mount persistent..."

# 🔁 Clean duplicate lines from mdadm.conf (optional safety)
sudo sed -i '/\/dev\/md0/d' /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf > /dev/null
sudo update-initramfs -u

# 🔁 Add mount to fstab (prevent duplicates)
grep -q "$RAID_DEVICE" /etc/fstab || echo "$RAID_DEVICE $MOUNTPOINT ext4 defaults,nofail,discard 0 0" | sudo tee -a /etc/fstab > /dev/null

echo "✅ RAID 0 array mounted successfully at $MOUNTPOINT"
