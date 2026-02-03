#!/usr/bin/env bash

set -e

echo "=============================="
echo " NetworkManager sanity check"
echo "=============================="
echo

echo "🧠 System:"
uname -r
echo

echo "🔌 Running network services:"
systemctl --type=service --state=running \
  | grep -E "NetworkManager|wpa_supplicant|networkd|iwd|connman|netctl" \
  || echo "  (nenhum serviço conflitante rodando)"
echo

echo "⚙️ Enabled services:"
for svc in NetworkManager wpa_supplicant systemd-networkd iwd connman netctl; do
  state=$(systemctl is-enabled "$svc" 2>/dev/null || echo "not-found")
  printf "  %-20s %s\n" "$svc" "$state"
done
echo

echo "📡 Devices:"
nmcli device status
echo

echo "🌍 Regulatory domain:"
iw reg get 2>/dev/null || echo "  iw not available"
echo

echo "📶 Saved Wi-Fi connections:"
nmcli -f NAME,UUID,DEVICE,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show \
  | sed '1d'
echo

echo "🔍 Wi-Fi scan:"
nmcli device wifi list 2>/dev/null | head -n 10 || echo "  scan failed"
echo

echo "=============================="
echo " Sanity check complete"
echo "=============================="
