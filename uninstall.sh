#!/bin/bash

SERVICE_NAME="etiquetei"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"

echo "Stopping the service..."
sudo systemctl stop $SERVICE_NAME

echo "Disabling the service..."
sudo systemctl disable $SERVICE_NAME

echo "Removing the service file..."
sudo rm -f $SERVICE_PATH

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Service $SERVICE_NAME has been uninstalled successfully."
