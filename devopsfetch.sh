#!/bin/bash

# Define log format
TIME_FORMAT="%Y-%m-%d %H:%M:%S"

# Function to display help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -p, --port <port_number>           Show all active ports or details for a specific port"
    echo "  -d, --docker <container_name>      Show all Docker images and containers, or details for a specific container"
    echo "  -n, --nginx <domain>               Show all Nginx domains and their ports, or details for a specific domain"
    echo "  -u, --users <username>             List all users and their last login times, or details for a specific user"
    echo "  -t, --time <start_date> [end_date] Show activities logged within the specified time range or on a specific day"
    echo "  -h, --help                         Display this help message and exit"
    echo
    echo "Examples:"
    echo "  $0 -p 80                 # Show details for port 80"
    echo "  $0 --docker              # List all Docker images and containers"
    echo "  $0 -n example.com        # Show Nginx configuration for example.com"
    echo "  $0 -u username           # Show details for user 'username'"
    echo "  $0 -t 2024-07-18 2024-07-22 # Show activities from July 18, 2024 to July 22, 2024"
    echo "  $0 -t 2024-07-21         # Show activities for July 21, 2024"
    exit 0
}

# Function to display active ports
show_ports() {
    if [ -z "$1" ]; then
        # Default listing: Show all open ports and their details
        lsof -i -P -n | grep -E '^COMMAND|LISTEN'
    else
        # Filter by port: Show only the specified port with detailed information
        local port="$1"
        lsof -i -n -P | awk -v port="$port" '
        BEGIN {
            printf "%-10s %-6s %-6s %-5s %-15s %-5s\n", "SERVICE", "PID", "USER", "TYPE", "NODE", "PORTS"
        }
        NR > 2 && $9 ~ ":"port {
            printf "%-10s %-6s %-6s %-5s %-15s %-5s\n", $1, $2, $3, $4, $9, $9
        }' | column -t || echo "Error: Port $port not found."
    fi
}


# Function to show Docker images and containers
show_docker() {
    if [ -z "$1" ]; then
        echo "Docker Images:"
        docker images

        echo ""
        echo "Docker Containers:"
        docker ps
    else
        echo "Details for Docker container $1:"
        docker inspect "$1" 2>/dev/null || echo "Error: Docker container/image $1 not found."
    fi
}

# Function to display Nginx configurations
show_nginx() {
    if [ -z "$1" ]; then
        sudo grep -E 'server_name' /etc/nginx/sites-enabled/*
    else
        sudo grep -E -A 8 "\b$1\b" /etc/nginx/sites-enabled/* | awk 'NR>2 {print $2, $3, $4}'
    fi
}

# Function to display user logins
show_users() {
    local username="$1"

    if [ -z "$username" ]; then
        # List all regular users with their last login times
        echo -e "Username\t\tLast Login"
        echo -e "----------------------------"

        # Get list of all users from /etc/passwd
        while IFS=: read -r user _ uid _; do
            # Only consider users with UID >= 1000 (regular users)
            if [ "$uid" -ge 1000 ]; then
                # Get last login time for each user
                last_login=$(lastlog -u "$user" 2>/dev/null | awk 'NR==2 {print $4, $5, $6, $7}')
                if [ -z "$last_login" ]; then
                    last_login="Never logged in"
                fi
                printf "%-20s %s\n" "$user" "$last_login"
            fi
        done < /etc/passwd
    else
        # Show details for a specific user
        if id "$username" &>/dev/null; then
            echo "User $username FOUND"
            # Show last login details for the specific user
            lastlog -u "$username" | awk 'NR==2 {print "Last Login: " $4, $5, $6, $7}'
        else
            echo "Error: User $username NOT FOUND!"
        fi
    fi
}

# Function to handle time range
handle_time_range() {
    local start_date="$1"
    local end_date="$2"

    # Ensure dates are formatted correctly
    start_date=$(date -d "$start_date" +"%Y-%m-%d" 2>/dev/null)
    end_date=$(date -d "$end_date" +"%Y-%m-%d" 2>/dev/null)

    # Check if start_date is valid
    if [ -z "$start_date" ]; then
        echo "Error: Invalid start date format. Allowed format Y-m-d"
        return 1
    fi

    # Handle cases where end_date is not provided
    if [ -z "$end_date" ]; then
        echo "Displaying system information for $start_date"
        journalctl --since "$start_date 00:00:00" --until "$start_date 23:59:59" | less
    else
        # Check if end_date is valid
        if [ -z "$end_date" ]; then
            echo "Error: Invalid end date format."
            return 1
        fi

        echo "Displaying system information from $start_date - $end_date"
        journalctl --since "$start_date 00:00:00" --until "$end_date 23:59:59" | less
    fi
}


# Main logic
case "$1" in
    -p|--port)
        shift
        show_ports "$1"
        ;;
    -d|--docker)
        shift
        show_docker "$1"
        ;;
    -n|--nginx)
        shift
        show_nginx "$1"
        ;;
    -u|--users)
        shift
        show_users "$1"
        ;;
    -t|--time)
        shift
        if [ -n "$1" ]; then
            handle_time_range "$1" "$2"
            # Shift for both dates if end date was provided
            [ -n "$2" ] && shift
        else
            echo "Error: Missing start date for --time option."
            exit 1
        fi
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid option. Use -h or --help for usage instructions."
        exit 1
        ;;
esac