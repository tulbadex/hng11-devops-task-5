# hng11-devops-task-5
# DevOps Fetch

`devopsfetch` is a tool designed for server information retrieval and monitoring. It provides details about active ports, Docker containers, Nginx configurations, user logins, and system activities within a specified time range.

## Installation and Configuration

### Prerequisites

- Ensure you have a Debian-based system (e.g., Ubuntu).
- You need `sudo` or root privileges to install packages and create systemd services.

### Installation Steps

1. **Download the `devopsfetch.sh` and `install.sh` Scripts**

   Save the `install.sh` and `devopsfetch.sh`  script to your preferred location.
   make sure they are in same location

2. **Make the Scripts Executable**

```bash
sudo chmod +x /path/to/install.sh
```

3. **Run the Installation Script**

```bash
sudo /path/to/install.sh
```
In my case it is
```bash
sudo ./install.sh
```
    This will:
    - Install necessary packages (`docker.io` and `nginx`).
    - Create and configure a systemd service for `devopsfetch.service`.
    - Reload systemd, enable, and start the `devopsfetch.service` service.

4. **Verify the Service**
```bash
sudo systemctl status devopsfetch.service
```

5. **Logging and Monitoring**

Ensure the log file is properly managed:
- Log Rotation: Use `logrotate` to handle log rotation and prevent the log file from growing indefinitely.

Create a logrotate configuration file /etc/logrotate.d/devopsfetch or cat it inside install.sh file
- Option 1:
```plaintext
/var/log/devopsfetch.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
    create 0644 root root
}
```

- Option 2:
```bash
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
```

# Usage Examples
## General Usage
    
```bash
devopsfetch [OPTIONS]
```
## Command-Line Flags

- Show Active Ports 
- Show Docker Images and Containers
- Show Nginx Configurations
- Show User Logins
- Show Logs Within a Time Range
- Display Help
