#!/usr/bin/env bash
set -euo pipefail
THEME_NAME="dying-light"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="/boot/grub/themes/${THEME_NAME}"
GRUB_DEFAULT="/etc/default/grub"
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo ./install.sh"; exit 1; }

mkdir -p "$DEST_DIR"
cp -f "$SRC_DIR"/*.png "$DEST_DIR/"
cp -f "$SRC_DIR"/*.ttf "$DEST_DIR/" 2>/dev/null || true
cp -f "$SRC_DIR"/*.pf2 "$DEST_DIR/" 2>/dev/null || true
cp -f "$SRC_DIR/theme.txt" "$DEST_DIR/"

# The .pf2 files shipped above are a pre-baked fallback. If grub-mkfont is
# available on this machine, regenerate fresh copies so the font always
# matches this GRUB build exactly (this is what v18's custom font skipped,
# and why it broke with PF2/CHIX errors).
if command -v grub-mkfont >/dev/null 2>&1 && [[ -f "$DEST_DIR/Anton-Regular.ttf" ]]; then
    echo "Generating Anton pf2 fonts..."
    grub-mkfont -s 16 -o "$DEST_DIR/anton_16.pf2" "$DEST_DIR/Anton-Regular.ttf" \
        || echo "WARNING: grub-mkfont -s 16 failed, keeping pre-baked anton_16.pf2"
    grub-mkfont -s 18 -o "$DEST_DIR/anton_18.pf2" "$DEST_DIR/Anton-Regular.ttf" \
        || echo "WARNING: grub-mkfont -s 18 failed, keeping pre-baked anton_18.pf2"
    grub-mkfont -s 28 -o "$DEST_DIR/anton_28.pf2" "$DEST_DIR/Anton-Regular.ttf" \
        || echo "WARNING: grub-mkfont -s 28 failed, keeping pre-baked anton_28.pf2"
else
    echo "grub-mkfont not found (or Anton-Regular.ttf missing) - using pre-baked pf2 files."
    echo "If text still shows as default GRUB font after install, run:"
    echo "  sudo grub-mkfont -s 16 -o $DEST_DIR/anton_16.pf2 $DEST_DIR/Anton-Regular.ttf"
    echo "  sudo grub-mkfont -s 18 -o $DEST_DIR/anton_18.pf2 $DEST_DIR/Anton-Regular.ttf"
    echo "  sudo grub-mkfont -s 28 -o $DEST_DIR/anton_28.pf2 $DEST_DIR/Anton-Regular.ttf"
fi

# Remove stale custom-font settings left by earlier Dying Light installers.
# GRUB_FONT controls the plain pre-theme console font, unrelated to theme.txt's
# own font strings above - leave it alone / cleared so it doesn't fight gfxterm.
if [[ -f "$GRUB_DEFAULT" ]]; then
    cp -f "$GRUB_DEFAULT" "${GRUB_DEFAULT}.dying-light-v19.bak" || true
    sed -i '/^GRUB_FONT=/d' "$GRUB_DEFAULT"
    sed -i '/^#GRUB_FONT=/d' "$GRUB_DEFAULT"
fi

set_kv(){
    local key="$1" val="$2"
    if grep -q "^${key}=" "$GRUB_DEFAULT"; then
        sed -i "s|^${key}=.*|${key}=${val}|" "$GRUB_DEFAULT"
    elif grep -q "^#${key}=" "$GRUB_DEFAULT"; then
        sed -i "s|^#${key}=.*|${key}=${val}|" "$GRUB_DEFAULT"
    else
        printf '%s=%s\n' "$key" "$val" >> "$GRUB_DEFAULT"
    fi
}

set_kv GRUB_THEME '"/boot/grub/themes/dying-light/theme.txt"'
set_kv GRUB_GFXMODE '"1920x1080"'
set_kv GRUB_GFXPAYLOAD_LINUX '"keep"'
set_kv GRUB_TERMINAL_OUTPUT '"gfxterm"'

if command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v update-grub >/dev/null 2>&1; then
    update-grub
else
    echo "ERROR: neither grub-mkconfig nor update-grub was found."
    exit 1
fi

echo
echo "Dying Light GRUB v21 installed successfully."
echo "Anton custom font active (menu + HUD labels); Unifont kept for the raw console."
echo "Selected-item bar and progress bar recolored/rebuilt to match the reference menu."
