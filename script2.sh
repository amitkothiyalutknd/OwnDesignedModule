#!/bin/bash

# Update package list and install Apache
echo "Updating packages and installing Apache..."
sudo apt update -y
sudo apt install apache2 -y

# Start Apache service and enable it to start on boot
echo "Starting Apache..."
sudo systemctl start apache2
sudo systemctl enable apache2

# Confirm Apache is running
if systemctl status apache2 | grep -q "active (running)"; then
    echo "Apache installation successful and running."
else
    echo "Apache installation failed."
    exit 1
fi

# Install AWS CLI (assuming you're on an Ubuntu instance)
echo "Installing AWS CLI..."
sudo apt install -y curl unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
rm -rf awscliv2.zip aws/

# Configure AWS CLI to access S3 (Make sure the IAM role for the instance has S3 permissions)
# Note: You may skip the following configuration commands if your instance has IAM role-based access to S3

# Set your desired S3 bucket name and region here
S3_BUCKET_NAME="moduled-bucket-2"
S3_REGION="us-east-1"  # Change this to your bucket's region
