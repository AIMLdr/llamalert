# Llamalert

**Llamalert** is a robust memory monitoring and alerting tool designed to keep track of `ollama`'s memory usage on Ubuntu 22.04 systems. It proactively notifies users via email and Slack when memory usage exceeds predefined thresholds, ensuring optimal performance and preventing resource overutilization.

- **Proactive Monitoring**: Continuously monitors `ollama`'s memory usage.
- **Threshold-Based Alerts**: Sends notifications when usage exceeds specified limits.
- **Multi-Channel Notifications**: Supports email and Slack integrations.
- **Logging**: Maintains a detailed log of all monitoring events.
- **Easy Configuration**: Simple setup and customization via environment variables.

## Prerequisites

Before installing Llamalert, ensure you have the following:

- **Operating System**: Ubuntu 22.04
- **`ollama`**: Installed and running on your system.
- **Administrative Privileges**: `sudo` access is required for installations and configurations.
- **Internet Connection**: Required for package installations and integrations.

## Installation

   ```bash
   git clone https://github.com/aimldr/llamalert.git
   cd llamalert
   ```
