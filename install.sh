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

# Main function to create the systemd service file
create_systemd_service() {
  SERVICE_NAME="etiquetei"
  USER=$(whoami)
  GROUP=$(id -gn)
  SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"
  EXECUTABLE_PATH="/home/$USER/${SERVICE_NAME}-application/$SERVICE_NAME"

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
  create_systemd_service
}

# Execute the main function
main
