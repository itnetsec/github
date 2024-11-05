#!/bin/bash

# Set script to exit on error
set -e

# Log file location
LOG_FILE="/var/log/app_installer.log"

# Firefox Developer Edition download URL and installation directory
FIREFOX_DEV_URL="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-US"
FIREFOX_INSTALL_DIR="/opt/firefox-dev"
FIREFOX_DESKTOP_FILE="/usr/share/applications/firefox-developer.desktop"

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_message "Error: Please run as root"
        exit 1
    fi
}

# Function to check system package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        log_message "Error: No supported package manager found"
        exit 1
    fi
}

# Function to update system
update_system() {
    local pkg_manager=$1
    log_message "Updating system packages..."
    
    case $pkg_manager in
        apt)
            apt-get update -y && apt-get upgrade -y
            ;;
        dnf)
            dnf update -y
            ;;
        yum)
            yum update -y
            ;;
        pacman)
            pacman -Syu --noconfirm
            ;;
    esac
}

# Function to install applications
install_apps() {
    local pkg_manager=$1
    shift
    local apps=("$@")
    
    log_message "Installing applications: ${apps[*]}"
    
    case $pkg_manager in
        apt)
            apt-get install -y "${apps[@]}"
            ;;
        dnf)
            dnf install -y "${apps[@]}"
            ;;
        yum)
            yum install -y "${apps[@]}"
            ;;
        pacman)
            pacman -S --noconfirm "${apps[@]}"
            ;;
    esac
}

# Function to install dependencies for Firefox Developer Edition
install_firefox_dependencies() {
    local pkg_manager=$1
    log_message "Installing Firefox Developer Edition dependencies..."
    
    case $pkg_manager in
        apt)
            apt-get install -y wget tar bzip2 libgtk-3-0 libdbus-glib-1-2
            ;;
        dnf|yum)
            dnf install -y wget tar bzip2 gtk3 dbus-glib
            ;;
        pacman)
            pacman -S --noconfirm wget tar bzip2 gtk3 dbus-glib
            ;;
    esac
}

# Function to install Firefox Developer Edition
install_firefox_developer() {
    log_message "Installing Firefox Developer Edition..."
    
    # Create installation directory
    mkdir -p "$FIREFOX_INSTALL_DIR"
    
    # Download and extract Firefox Developer Edition
    log_message "Downloading Firefox Developer Edition..."
    wget -qO- "$FIREFOX_DEV_URL" | tar xj -C "$FIREFOX_INSTALL_DIR" --strip-components=1
    
    # Create desktop entry
    cat > "$FIREFOX_DESKTOP_FILE" << EOL
[Desktop Entry]
Name=Firefox Developer Edition
GenericName=Web Browser
Comment=Browse the World Wide Web
Exec=$FIREFOX_INSTALL_DIR/firefox %u
Terminal=false
Type=Application
Icon=$FIREFOX_INSTALL_DIR/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;Developer;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOL

    # Set permissions
    chmod 755 "$FIREFOX_DESKTOP_FILE"
    
    # Create symbolic link
    ln -sf "$FIREFOX_INSTALL_DIR/firefox" /usr/local/bin/firefox-dev
    
    log_message "Firefox Developer Edition installation completed"
}

# Main script execution
main() {
    # Check if running as root
    check_root
    
    # Create log file if it doesn't exist
    touch "$LOG_FILE"
    
    log_message "Starting application installation script"
    
    # Detect package manager
    PKG_MANAGER=$(detect_package_manager)
    log_message "Detected package manager: $PKG_MANAGER"
    
    # Update system first
    update_system "$PKG_MANAGER"
    
    # List of applications to install
    APPS=(
        "vim"
        "git"
        "curl"
        "wget"
        "htop"
        "tmux"
    )
    
    # Install applications
    install_apps "$PKG_MANAGER" "${APPS[@]}"
    
    # Install Firefox Developer Edition dependencies
    install_firefox_dependencies "$PKG_MANAGER"
    
    # Install Firefox Developer Edition
    install_firefox_developer
    
    log_message "Installation completed successfully"
    log_message "Firefox Developer Edition can be launched using 'firefox-dev' command or from the applications menu"
}

# Error handling
trap 'log_message "Error: Installation failed on line $LINENO"' ERR

# Run main function
main
