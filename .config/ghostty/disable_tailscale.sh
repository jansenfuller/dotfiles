#!/bin/bash
# Disable Tailscale network extension
echo "Disabling Tailscale network extension..."
# Kill any running Tailscale processes
sudo pkill -f "tailscale" 2>/dev/null || true
sudo pkill -f "io.tailscale.ipn.macsys" 2>/dev/null || true
# Remove network extension files
sudo rm -rf "/Library/SystemExtensions/9E9EDC6E-344B-4683-8AC3-C8E7F6D55812" 2>/dev/null || true
# Remove extension preferences
sudo defaults delete /Library/Preferences/com.apple.networkextension "io.tailscale.ipn.macsys" 2>/dev/null || true
sudo defaults delete /Library/Preferences/com.apple.networkextension "io.tailscale.ipn.macsys.network-extension" 2>/dev/null || true
# Flush DNS and restart network
sudo dscacheutil -flushcache 2>/dev/null || true
sudo killall -HUP mDNSResponder 2>/dev/null || true
echo "Tailscale network extension disabled. Please restart your computer for changes to take full effect."
