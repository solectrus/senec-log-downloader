#!/bin/bash

# This script downloads the log files from a SENEC device.
#
# It requires an .env file with the following variables:
# - SENEC_HOST: Host name or IP address of your SENEC device
# - INSTALLATION_DATE: Date of installation in the format "YYYY-MM-DD"
# - SENEC_SCHEMA (optional): http or https (default)

########## NO NEED TO CHANGE ANYTHING HERE (UNLESS YOU KNOW WHAT YOU'RE DOING) #############################

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Error: .env file not found!"
    exit 1
else
    source ".env"
fi

# Ensure SENEC_HOST and INSTALLATION_DATE are set in .env
if [ -z "$SENEC_HOST" ] || [ -z "$INSTALLATION_DATE" ]; then
    echo "Error: SENEC_HOST and INSTALLATION_DATE must be defined in .env!"
    exit 1
fi

# Use SENEC_SCHEMA from .env if available, default to https
senec_schema=${SENEC_SCHEMA:-https}

# Use Host name or IP address of the SENEC device from .env
senec_host=$SENEC_HOST

# Use Day of installation from .env
installation_date=$INSTALLATION_DATE

# Start downloading from the last day where a log file exists
latest_file=$(find ./logs -type f -name "*.log" | sort -r | head -n 1)

if [[ -z "$latest_file" ]]; then
    echo "No log files found. Starting from installation date: $installation_date"
    start_date=$installation_date
else
    day=$(basename $latest_file .log)
    month=$(basename $(dirname $latest_file))
    year=$(basename $(dirname $(dirname $latest_file)))
    start_date="$year-$month-$day"
fi

## Download until today
end_date=$(date +"%Y-%m-%d")

# Define base URL with the schema from .env or default
base_url="${senec_schema}://$senec_host//Log"

# Initialize current_date to start_date
current_date=$start_date

# Loop through each day between start and end dates
while [[ "$current_date" < "$end_date" ]] || [[ "$current_date" == "$end_date" ]]; do
    year=$(echo $current_date | awk -F- '{print $1}')
    month=$(echo $current_date | awk -F- '{print $2}')
    day=$(echo $current_date | awk -F- '{print $3}')

    # Create target folder (grouped by year and month)
    mkdir -p "logs/$year/$month"

    # Download single file
    url="$base_url/$year/$month/$day.log"
    filename="logs/$year/$month/$day.log"
    echo "Downloading from $url"
    curl -Ssk -o "$filename" "$url"

    # Check the operating system and use the appropriate commands
    if [[ $(uname) == "Darwin" ]]; then # Mac OS X
        # Increment date
        current_date=$(date -j -v+1d -f "%Y-%m-%d" "$current_date" +"%Y-%m-%d")
    else # Linux
        # Increment date
        current_date=$(date -d "$current_date + 1 day" +"%Y-%m-%d")
    fi
done
