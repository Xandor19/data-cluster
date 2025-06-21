su_exit_code=0

while getopts "u:" opt; do
  case $opt in
    u) USERNAME="$OPTARG" ;;
    *) echo "Usage: $0 -u <username>"; exit 1 ;;
  esac
done

if [ -z "$USERNAME" ]; then
  echo "No user specified. Please provide a username with -u option."
  su_exit_code=1
elif ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
  echo "Invalid username."
  su_exit_code=1
elif ! id "$USERNAME" >/dev/null 2>&1; then
  echo "User '$USERNAME' does not exist. Please create the user first."
  su_exit_code=1
fi

if [ "$su_exit_code" -eq 0 ]; then
  echo "Setting up sudo access for '$USERNAME'..."
  
  # Create temporary script file
  TEMP_SCRIPT=$(mktemp)
  trap "rm -f $TEMP_SCRIPT" EXIT
  
  cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash

# Check if sudo is already installed
if command -v sudo >/dev/null 2>&1; then
    echo "Sudo is already installed. Skipping installation."
else
    echo "Updating package lists..."
    apt update
    
    echo "Installing sudo package..."
    apt install sudo -y
    echo "Sudo has been installed successfully."
fi

# Check if user is already in sudo group
if groups '$USERNAME' | grep -q '\bsudo\b'; then
    echo "User '$USERNAME' is already in the sudo group. No changes needed."
else
    echo "Adding user '$USERNAME' to sudo group..."
    /usr/sbin/usermod -aG sudo '$USERNAME'
    echo "User '$USERNAME' has been added to the sudo group."
fi
EOF

  # Make it executable
  chmod 500 "$TEMP_SCRIPT"

  # Execute as root
  su -c "$TEMP_SCRIPT"
  su_exit_code=$?

  # Clean up
  rm -f "$TEMP_SCRIPT"
fi

if [ "$su_exit_code" -eq 0 ]; then
  echo "Sudo setup complete for user $USERNAME."
  echo "Please log out and log back in for the changes to take effect."
else
  echo "Sudo setup failed with exit code $su_exit_code."
  echo "Please fix the indicated error and try again."
  exit $su_exit_code
fi
