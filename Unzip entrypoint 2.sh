#!/bin/bash

# Function to install required packages
install_packages() {
    sudo apt-get update
    sudo apt-get install -y curl wget zip unzip jq
    if ! command -v pip &> /dev/null; then
        sudo apt-get install -y python3-pip
    fi
    if ! command -v Xvfb &> /dev/null; then
        sudo apt-get install -y xvfb
    fi
}

# Function to install Python dependencies from requirements.txt
install_python_dependencies() {
    if [ -f "requirements.txt" ]; then
        if command -v pip &> /dev/null; then
            pip install -r requirements.txt
        elif command -v pip3 &> /dev/null; then
            pip3 install -r requirements.txt
        else
            echo "pip is not installed. Please install pip or pip3."
            exit 1
        fi
    else
        echo "requirements.txt not found. Skipping Python dependencies installation."
    fi
}

# Function to kill all related processes
kill_related_processes() {
    pkill -f "python /app/main.py"
    pkill -f chrome
    pkill -f undetected_chromedriver
}

# Function to display IP and system information
display_ip_info() {
    IP_INFO=$(curl -s ipinfo.io)
    IP=$(echo $IP_INFO | jq -r '.ip')
    ISP=$(echo $IP_INFO | jq -r '.org')
    COUNTRY=$(echo $IP_INFO | jq -r '.country')
    REGION=$(echo $IP_INFO | jq -r '.region')
    CITY=$(echo $IP_INFO | jq -r '.city')
    HOSTNAME=$(hostname)
    echo "Hostname: $HOSTNAME"
    echo "IP Address: $IP"
    echo "ISP: $ISP"
    echo "Country: $COUNTRY"
    echo "Region: $REGION"
    echo "City: $CITY"
}

# Install required packages
install_packages

# Install Python dependencies
install_python_dependencies

# Remove temp file when previous execution crashed
rm -f /tmp/.X99-lock

# Set display port and dbus env to avoid hanging
# (https://github.com/joyzoursky/docker-python-chromedriver)
export DISPLAY=:99
export DBUS_SESSION_BUS_ADDRESS=/dev/null

# Display IP and system information
display_ip_info

# Start virtual display
Xvfb $DISPLAY -screen 0 1280x800x16 -nolisten tcp &

ls

# Download the zip file directly
curl -L -o /app/partial_session_data.zip "https://tvkkdata.tvkishorkumardata.workers.dev/download.aspx?file=Y5ypRtUko7wRfW1kfZxt6Y4qGi13ru%2BUmBnJoc%2FDhBh8AbJUWA8wP8IBzMHwiK49&expiry=E0nPuvTYKldc7LAovpWF%2Fw%3D%3D&mac=0cd81adeba2362a95c7dd07bc6b2fefa89d776d965f6f2394b8af0b60c726cbe"
echo "Download completed."

sleep 15

ls

chmod 777 /app/partial_session_data.zip

sleep 15

# Check if the zip file exists and unzip it
if [ -f /app/partial_session_data.zip ]; then
    unzip -o /app/partial_session_data.zip -d /app/
    echo "First unzip completed."
    # Unzip the nested zip file
    unzip -o /app/partial_session_data/partial_sessions.zip -d /app/
    echo "Second unzip completed."
    # Move the sessions folder to the correct location
    mv /app/partial_session_data/partial_sessions/app/sessions /app/sessions
    echo "Sessions folder moved successfully."
    # List the contents to verify
    ls -l /app/sessions
else
    echo "No session data zip file found."
fi

# Kill all related processes
kill_related_processes

# Wait for 10 seconds
sleep 10

# Run the main Python script
python /app/main.py -cv 127 -v -g IN --proxy http://tvkk:13579@52.66.214.15:3128

# Wait for 10 seconds
sleep 10

# Run the main Python script again
python /app/main.py -cv 127 -v -g IN --proxy http://tvkk:13579@52.66.214.15:3128

# Kill all related processes again
kill_related_processes
