# WireGuard VPN Setup Automation

This repository provides an automated way to set up and test a WireGuard VPN using an Azure VM. It includes Terraform for provisioning, bash scripts for configuration, and tools for testing the VPN from macOS.

---

## Features

- **Provisioning**: Automate the creation of an Azure VM with Terraform.
- **Configuration**: Automate the setup of WireGuard on the server using Bash scripts.
- **Testing**: Simplified testing of the VPN connection from macOS.

---

## File Structure

```plaintext
wireguard-vpn-setup-automation/
│
├── configs/
│   ├── macbook.conf         # Example client configuration for macOS
│   └── server.conf          # Example server configuration
│
├── scripts/
│   ├── provision.sh         # Script to provision the WireGuard server
│   ├── configure-server.sh  # Script to configure WireGuard on the server
│   ├── vpn_test.sh          # Script to test the VPN on macOS
│
├── terraform/
│   ├── main.tf              # Terraform script to provision Azure VM
│   ├── variables.tf         # Terraform variables file
│   ├── outputs.tf           # Terraform outputs file
│
├── README.md                # Project documentation
├── LICENSE                  # Project license (e.g., MIT)
└── .gitignore               # Git ignore file
