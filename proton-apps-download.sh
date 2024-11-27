#!/bin/bash

# Proton Apps Download Script
# This script downloads various Proton apps for Linux

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to download with wget or curl
download_file() {
    if command_exists wget; then
        wget -O "$2" "$1"
    elif command_exists curl; then
        curl -L "$1" -o "$2"
    else
        echo "Error: Neither wget nor curl is available. Please install one of them."
        exit 1
    fi
}

# Create a directory for downloads
DOWNLOAD_DIR="$HOME/proton-apps"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Proton VPN Download
echo "Downloading Proton VPN..."
PROTON_VPN_URL=$(curl -s https://protonvpn.com/download/ | grep -oP 'https://[^"]*\.AppImage' | head -n 1)
if [ -n "$PROTON_VPN_URL" ]; then
    download_file "$PROTON_VPN_URL" "ProtonVPN.AppImage"
    chmod +x ProtonVPN.AppImage
else
    echo "Could not find Proton VPN download URL"
fi

# Proton Drive (if available as a Linux app)
echo "Downloading Proton Drive (if available)..."
PROTON_DRIVE_URL=$(curl -s https://proton.me/drive/download | grep -oP 'https://[^"]*\.AppImage' | head -n 1)
if [ -n "$PROTON_DRIVE_URL" ]; then
    download_file "$PROTON_DRIVE_URL" "ProtonDrive.AppImage"
    chmod +x ProtonDrive.AppImage
else
    echo "Could not find Proton Drive download URL"
fi

# Proton Calendar (if available as a Linux app)
echo "Downloading Proton Calendar (if available)..."
PROTON_CALENDAR_URL=$(curl -s https://proton.me/calendar/download | grep -oP 'https://[^"]*\.AppImage' | head -n 1)
if [ -n "$PROTON_CALENDAR_URL" ]; then
    download_file "$PROTON_CALENDAR_URL" "ProtonCalendar.AppImage"
    chmod +x ProtonCalendar.AppImage
else
    echo "Could not find Proton Calendar download URL"
fi

# Proton Pass (if available as a Linux app)
echo "Downloading Proton Pass (if available)..."
PROTON_PASS_URL=$(curl -s https://proton.me/pass/download | grep -oP 'https://[^"]*\.AppImage' | head -n 1)
if [ -n "$PROTON_PASS_URL" ]; then
    download_file "$PROTON_PASS_URL" "ProtonPass.AppImage"
    chmod +x ProtonPass.AppImage
else
    echo "Could not find Proton Pass download URL"
fi

# List downloaded files
echo -e "\nDownloaded files:"
ls -l "$DOWNLOAD_DIR"

# Print instructions
echo -e "\nDownload complete! Files are located in $DOWNLOAD_DIR"
echo "To run the apps, navigate to the directory and execute the .AppImage files"
echo "Note: You may need to make the files executable with 'chmod +x filename' if not already done"
