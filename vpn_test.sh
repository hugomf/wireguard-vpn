#!/bin/bash

# WireGuard configuration file path
CONFIG_FILE="macbook.conf"

# Function to check if WireGuard tools are installed
check_requirements() {
    if ! command -v wireguard-go &>/dev/null || ! command -v wg-quick &>/dev/null; then
        echo "WireGuard tools are not installed. Installing..."
        brew install wireguard-tools
    else
        echo "WireGuard tools are installed."
    fi
}

# Function to import WireGuard configuration
import_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "Using configuration file: $CONFIG_FILE"
        sudo cp "$CONFIG_FILE" /usr/local/etc/wireguard/wg0.conf
    else
        echo "Configuration file $CONFIG_FILE not found! Please place it in the script directory."
        exit 1
    fi
}

# Function to start WireGuard
start_vpn() {
    echo "Starting WireGuard VPN..."
    sudo wg-quick up wg0
    if [ $? -eq 0 ]; then
        echo "VPN started successfully."
    else
        echo "Failed to start VPN. Check the configuration and try again."
        exit 1
    fi
}

# Function to verify the VPN connection
verify_connection() {
    echo "Verifying VPN connection..."
    VPN_IP=$(curl -s ifconfig.me)
    if [ -z "$VPN_IP" ]; then
        echo "Failed to verify VPN connection. Is the internet accessible?"
        exit 1
    fi
    echo "Your public IP is: $VPN_IP (should match your VPN server's public IP)"
    echo "Pinging VPN server (10.0.0.1)..."
    ping -c 4 10.0.0.1
}

# Function to stop WireGuard VPN
stop_vpn() {
    echo "Stopping WireGuard VPN..."
    sudo wg-quick down wg0
    echo "VPN stopped."
}

# Main menu
main_menu() {
    echo "WireGuard VPN Test Script"
    echo "1. Start VPN"
    echo "2. Verify VPN Connection"
    echo "3. Stop VPN"
    echo "4. Exit"
    read -p "Choose an option: " option

    case $option in
    1)
        check_requirements
        import_config
        start_vpn
        ;;
    2)
        verify_connection
        ;;
    3)
        stop_vpn
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid option. Try again."
        ;;
    esac
}

# Run the menu in a loop
while true; do
    main_menu
done
