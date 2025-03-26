#!/bin/sh
# Script to set correct permissions on SSH host keys after system build.

echo "Setup SSH host key and some directories permissions"

# Path to the directory containing SSH keys
SSH_KEY_DIR="$TARGET_DIR/etc/ssh"

# Path to the /var/empty with wrong permissions
VAR_EMPTY_DIR="$TARGET_DIR/var/empty"

echo "Target directory: $TARGET_DIR"
echo "Full key path directory: $SSH_KEY_DIR"

# List of SSH key file names
KEY_FILES="ssh_host_rsa_key ssh_host_ecdsa_key ssh_host_ed25519_key"

# Iterate over each key file and set permissions to 600 (read/write for owner only)
for key in $KEY_FILES; do
    key_path="$SSH_KEY_DIR/$key"
    
    # Check if the key file exists
    if [ -f "$key_path" ]; then
        echo "Setting permissions for $key_path"
        chmod 600 "$key_path"
    else
        echo "Key file not found: $key_path"
    fi
done


# Change ownership and permissions of /var/empty
if [ -d "$VAR_EMPTY_DIR" ]; then
    echo "Setting permissions for $VAR_EMPTY_DIR"
    chown root:root "$VAR_EMPTY_DIR"
    chmod -R 755 "$VAR_EMPTY_DIR"
else
    echo "Directory not found: $VAR_EMPTY_DIR"
fi

echo "SSH host key and some directories permissions setup completed."
