#!/bin/bash

# Function to display a list and get the user's choice
choose_environment() {
  echo "Choose the environment:"
  select env in "development" "production"; do
    case $env in
      development ) echo "Environment chosen: development"; NODE_ENV="development"; break;;
      production ) echo "Environment chosen: production"; NODE_ENV="production"; break;;
      * ) echo "Invalid option, please choose 1 or 2.";;
    esac
  done
}

# Function to get the encryption key from the user
get_encryption_key() {
  read -p "Enter the encryption key (press Enter to use default): " APP_KEY
  if [ -z "$APP_KEY" ]; then
    APP_KEY="Yoda"
    echo "Using default encryption key: Yoda"
  else
    echo "Encryption key chosen: $APP_KEY"
  fi
}

# Function to choose the instalattion path
choose_installation_path() {
  read -p "Enter the installation path (press Enter to use default): " INSTALLATION_PATH
  if [ -z "$INSTALLATION_PATH" ]; then
    INSTALLATION_PATH="/etc/etiquetei/application"
    echo "Using default installation path: /etc/etiquetei/application"
  else
    echo "Installation path chosen: $INSTALLATION_PATH"
  fi
}

# Function to clone the repository
clone_repository() {
  REPO_URL="https://github.com/etiquetei/application-releases.git"
  echo "Cloning repository from $REPO_URL to $INSTALLATION_PATH..."
  git clone $REPO_URL $INSTALLATION_PATH
  if [ $? -eq 0 ]; then
    echo "Repository cloned successfully."
  else
    echo "Failed to clone the repository."
    exit 1
  fi
}

# Function to copy the update.sh script to the specified path with the necessary permissions
copy_update_script() {
  BASE_PATH=$(dirname "$INSTALLATION_PATH")
  SCRIPTS_PATH="$BASE_PATH/scripts"
  SOURCE_SCRIPT="update.sh"
  DEST_SCRIPT="$SCRIPTS_PATH/update.sh"

  # Create the scripts directory if it doesn't exist
  if [ ! -d "$SCRIPTS_PATH" ]; then
    echo "Creating directory $SCRIPTS_PATH..."
    mkdir -p "$SCRIPTS_PATH"
  fi

  # Copy the script file with executable permissions
  echo "Copying update script file to $DEST_SCRIPT..."
  cp "$SOURCE_SCRIPT" "$DEST_SCRIPT"

  # Make the script executable
  chmod +x "$DEST_SCRIPT"

  echo "Script file copied and made executable at $DEST_SCRIPT."
}

# Main function to create the systemd service file
create_systemd_service() {
  SERVICE_NAME="etiquetei"
  USER=$(whoami)
  GROUP=$(id -gn)
  SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"
  EXECUTABLE_PATH="/$INSTALLATION_PATH/$SERVICE_NAME"

  echo "Creating systemd service file at $SERVICE_PATH..."

  sudo bash -c "cat > $SERVICE_PATH <<EOL
[Unit]
Description=Etiquetei Service
After=network.target

[Service]
ExecStart=$EXECUTABLE_PATH
Restart=on-failure
RestartSec=10
User=$USER
Group=$GROUP
Environment=NODE_ENV=$NODE_ENV
Environment=APP_KEY=$APP_KEY

[Install]
WantedBy=multi-user.target
EOL"

  echo "Systemd service file created successfully."

  # Reload systemd configuration files
  echo "Reloading systemd daemon..."
  sudo systemctl daemon-reload

  # Start and enable the service
  echo "Starting the service..."
  sudo systemctl start $SERVICE_NAME

  echo "Enabling the service to start automatically on boot..."
  sudo systemctl enable $SERVICE_NAME

  echo "Service $SERVICE_NAME configured and started successfully."
}

# Function to prompt the user for information and execute service creation
main() {
  choose_environment
  get_encryption_key
  choose_installation_path
  clone_repository
  copy_update_script

  echo "Running update script $DEST_SCRIPT..."
  bash "$DEST_SCRIPT"

  CRONJOB_SCRIPT="cronjob.sh"
  echo "Running cronjob script $CRONJOB_SCRIPT..."
  bash "$CRONJOB_SCRIPT"

  create_systemd_service
}

# Execute the main function
main
