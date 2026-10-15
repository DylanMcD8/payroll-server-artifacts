#!/bin/bash
set -euo pipefail

release_url="https://github.com/DylanMcD8/payroll-server-artifacts/releases/latest/download"
downloads="$HOME/swen-543/downloads"
backend_root="$HOME/swen-543/payroll_server"
backend="$backend_root/auto-manf-payroll-server"

echo "Checking MongoDB..."
if ! systemctl is-active --quiet mongod; then
    echo "MongoDB is not running. Start it before deploying."
    exit 1
fi

if [[ ! -f "$backend/.env" ]]; then
    echo "Missing backend configuration: $backend/.env"
    exit 1
fi

mkdir -p "$downloads"

echo "Downloading backend..."
curl -fL "$release_url/payroll-server.zip" \
    -o "$downloads/payroll-server.zip"

echo "Downloading frontend..."
curl -fL "$release_url/payroll-client.zip" \
    -o "$downloads/payroll-client.zip"

echo "Checking ZIP files..."
unzip -tq "$downloads/payroll-server.zip"
unzip -tq "$downloads/payroll-client.zip"

echo "Updating backend files..."
unzip -o "$downloads/payroll-server.zip" \
    -d "$backend_root" \
    -x 'auto-manf-payroll-server/.env'

echo "Installing backend dependencies..."
cd "$backend"
npm ci --omit=dev

echo "Deploying frontend..."
sudo mkdir -p /var/www/html/payroll
sudo unzip -o "$downloads/payroll-client.zip" \
    -d /var/www/html/payroll

echo "Deployment files installed successfully. Restart payroll backend."