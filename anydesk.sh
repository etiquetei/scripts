#!/bin/bash

# Step 1: Download AnyDesk for ARM64
echo "Downloading AnyDesk for ARM64..."
wget -O anydesk_arm64.deb https://download.anydesk.com/rpi/anydesk_6.3.0-1_armhf.deb

# Step 2: Install Necessary Libraries
echo "Installing necessary libraries..."
sudo apt install -y libpolkit-gobject-1-0:armhf libraspberrypi0:armhf libraspberrypi-dev:armhf libraspberrypi-bin:armhf libgles-dev:armhf libegl-dev:armhf

# Creating symbolic links
echo "Creating symbolic links..."
sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so /usr/lib/libbrcmGLESv2.so
sudo ln -s /usr/lib/arm-linux-gnueabihf/libEGL.so /usr/lib/libbrcmEGL.so

# Step 3: Install AnyDesk
echo "Installing AnyDesk..."
sudo dpkg -i anydesk_arm64.deb
rm -rf anydesk_arm64.deb

# Fixing dependencies if needed
echo "Fixing dependencies if needed..."
sudo apt-get install -f -y

# Step 4: Launch AnyDesk
echo "Starting AnyDesk..."
sudo systemctl start anydesk && anydesk

# Step 5: Configuring unattended access
sudo echo etiquetei@2024 | sudo anydesk --set-password

echo "AnyDesk installed successfully. AnyDesk ID is displayed below:"
anydesk --get-id
