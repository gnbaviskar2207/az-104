#!/usr/bin/env bash
set -euo pipefail

disk="$(lsblk -dpno NAME,TYPE | awk '$2=="disk" && $1!="/dev/sda" {print $1; exit}')"
if [[ -z "$disk" ]]; then
  echo 'No non-OS disk found.' >&2
  exit 1
fi

sudo parted "$disk" --script mklabel gpt mkpart primary ext4 0% 100%
sudo mkfs.ext4 "${disk}1"
sudo mkdir -p /data
uuid="$(sudo blkid -s UUID -o value "${disk}1")"
echo "UUID=${uuid} /data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
sudo mount -a
echo 'snapshot marker' | sudo tee /data/marker.txt
df -h /data
