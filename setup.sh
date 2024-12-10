#!/bin/bash

# Run Terraform
echo "Provisioning Azure VM with Terraform..."
terraform init
terraform apply -auto-approve

# Extract VM IP
VM_IP=$(terraform output -raw public_ip)

# Update Ansible inventory
echo "[vpn]" > inventory
echo "$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa" >> inventory

# Run Ansible
echo "Configuring WireGuard VPN with Ansible..."
ansible-playbook -i inventory vpn.yml --ssh-extra-args='-o StrictHostKeyChecking=no'
