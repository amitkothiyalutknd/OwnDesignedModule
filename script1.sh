#!/bin/bash

# Update package list and install Nginx
echo "Updating packages and installing Nginx..."
sudo apt update -y
sudo apt install nginx -y

# Start Nginx service and enable it to start on boot
echo "Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Confirm Nginx is running
if systemctl status nginx | grep -q "active (running)"; then
    echo "Nginx installation successful and running."
else
    echo "Nginx installation failed."
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

S3_BUCKET_NAME="moduled-bucket-1"
S3_REGION="us-east-1"  # Change this to your bucket's region
