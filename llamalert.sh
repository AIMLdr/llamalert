# llamalert.sh (c) 2025 codephreak
#!/bin/bash

###########################################
# Llamalert - Ollama Memory Usage Monitor #
# Author: Gregory L. Magnusson            #
# Date: 2025-01-12                        #
###########################################

# -------------------------------
# Configuration Parameters
# -------------------------------

# Thresholds in MB
THRESHOLD=4000          # Primary memory threshold in MB
WARNING_THRESHOLD=3500  # Warning threshold in MB

# Email Configuration
EMAIL="your_email@example.com"          # Destination email address for alerts
FROM_EMAIL="draiml@localhost"            # Sender email address
SUBJECT_MEM="Llamalert: Ollama Memory Usage Alert"     # Subject for critical alerts
SUBJECT_WARN="Llamalert: Ollama Memory Usage Warning"  # Subject for warning alerts

# Slack Webhook Configuration (Optional)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/webhook/url"  # Replace with your Slack webhook URL

# Log File Location
LOG_FILE="$HOME/llamalert.log"          # Path to the log file

# Ollama Process Name
PROCESS_NAME="ollama"                   # Exact name of the Ollama process

# -------------------------------
# Function to Send Alert Email
# -------------------------------

send_email_alert() {
    local used_memory=$1
    local threshold=$2
    local subject=$3
    local message=$4

    echo "$message" | mail -s "$subject" -r "$FROM_EMAIL" "$EMAIL"
}

# -------------------------------
# Function to Send Slack Notification
# -------------------------------

send_slack_alert() {
    local message=$1

    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        # Prepare JSON payload using jq
        local payload
        payload=$(jq -n --arg text "$message" '{text: $text}')

        # Send POST request to Slack webhook
        curl -s -X POST -H 'Content-type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL" > /dev/null
    fi
}

# -------------------------------
# Function to Log Messages
# -------------------------------

log_message() {
    local message=$1
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# -------------------------------
# Main Script Execution
# -------------------------------

# Get memory usage of ollama in MB
USED=$(ps -o rss= -C "$PROCESS_NAME" | awk '{sum += $1} END {printf "%.0f", sum/1024}')

# Check if process is running
if [ -z "$USED" ]; then
    log_message "WARNING: $PROCESS_NAME process not found."
    exit 1
fi

# Compare used memory with thresholds
if [ "$USED" -gt "$THRESHOLD" ]; then
    # Prepare alert message
    MESSAGE="*ALERT:* $PROCESS_NAME is using *${USED}MB* of RAM, which exceeds the threshold of *${THRESHOLD}MB*."

    # Send alert email from draiml@localhost
    send_email_alert "$USED" "$THRESHOLD" "$SUBJECT_MEM" "$MESSAGE"

    # Send Slack notification
    send_slack_alert "$MESSAGE"

    # Log the event
    log_message "ALERT: $PROCESS_NAME memory usage is ${USED}MB, exceeding the threshold of ${THRESHOLD}MB."
elif [ "$USED" -gt "$WARNING_THRESHOLD" ]; then
    # Prepare warning message
    MESSAGE="*WARNING:* $PROCESS_NAME is using *${USED}MB* of RAM, approaching the threshold of *${THRESHOLD}MB*."

    # Send warning email from draiml@localhost
    send_email_alert "$USED" "$THRESHOLD" "$SUBJECT_WARN" "$MESSAGE"

    # Send Slack notification
    send_slack_alert "$MESSAGE"

    # Log the event
    log_message "WARNING: $PROCESS_NAME memory usage is ${USED}MB, approaching the threshold of ${THRESHOLD}MB."
else
    # Log normal operation
    log_message "$PROCESS_NAME memory usage is ${USED}MB."
fi

exit 0
