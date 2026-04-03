#!/bin/bash
# =======================================
# Linux User Account Creation Script
# Author: Your Name
# Description: Creates a new Linux user, sets a password,
# and forces password change on first login.
# =======================================

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root (use sudo)."
  exit 1
fi

# Prompt for username
read -p "Enter the username to create: " USERNAME

# Prompt for full name or comment (optional)
read -p "Enter full name (optional): " COMMENT

# Create the user with home directory
useradd -m -c "$COMMENT" "$USERNAME"

# Check if user creation was successful
if [[ $? -ne 0 ]]; then
  echo "Failed to create user. Please check the username or try again."
  exit 1
fi

# Set password for user
passwd "$USERNAME"

# Force password change on first login
chage -d 0 "$USERNAME"

# Confirm success
echo "✅ User '$USERNAME' created successfully!"
echo "Home directory: /home/$USERNAME"
echo "Password will need to be changed at first login."

