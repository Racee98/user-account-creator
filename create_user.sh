#!/bin/bash
# =======================================
# Linux User Account Creation Script
# Author: Your Name
# Description: Creates a new Linux user, sets a password,
# and forces password change on first login.
# =======================================

LOGFILE="/var/log/user-audit.log"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
  echo "Please run this script as root (use sudo)."
  exit 1
fi

# Prompt for username
read -p "Enter the username to create: " USERNAME

if [[ -z "$USERNAME" ]]; then
  echo "Error: Username cannot be empty."
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  echo "Error: User '$USERNAME' already exists."
  exit 1
fi

if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Error: Invalid username format."
  exit 1
fi

# Prompt for full name or comment (optional)
read -p "Enter full name (optional): " COMMENT

# Prompt for group assignment (optional)
read -p "Enter group to assign (leave blank to skip): " GROUP

# Create the user with home directory
useradd -m -c "$COMMENT" "$USERNAME"

# Check if user creation was successful
if [[ $? -ne 0 ]]; then
  echo "Failed to create user. Please check the username or try again."
  exit 1
fi

if [[ -n "$GROUP" ]]; then
  if getent group "$GROUP" &>/dev/null; then
    usermod -aG "$GROUP" "$USERNAME"
    echo " Added '$USERNAME' to group '$GROUP'"
  else
    echo " Group '$GROUP' does not exist. Skipping."
  fi
fi

# Set password for user
passwd "$USERNAME"

# Force password change on first login
chage -d 0 "$USERNAME"

# Confirm success
echo " User '$USERNAME' created successfully!"
echo "Home directory: /home/$USERNAME"
echo "Password will need to be changed at first login."
echo "$(date '+%Y-%m-%d %H:%M:%S') | USER CREATED | $USERNAME | by ${SUDO_USER:-root}" >> "$LOGFILE"
echo " Logged to $LOGFILE"

