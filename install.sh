#!/bin/bash

# Install necessary packages
apt-get update
apt-get install -y docker.io nginx

# Copy devopsfetch.sh to /usr/local/bin
cp devopsfetch.sh /usr/local/bin/devopsfetch
chmod +x /usr/local/bin/devopsfetch

# Create systemd service
SERVICE_FILE="/etc/systemd/system/devopsfetch.service"

cat <<EOT > $SERVICE_FILE
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/devopsfetch
Restart=always

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd and start service
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

cat <<EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 0644 root root
}
EOF

echo "Installation complete. Service devopsfetch is now running."
