#!/bin/bash

# Define host name or IP address of your SENEC device
senec_host="senec.fritz.box"

# Day of installation, the very first day where a log file exists
installation_date="2020-11-27"

########## DON'T CHANGE ANYTHING BELOW (UNLESS YOU KNOW WHAT YOU'RE DOING) #############################

# Start downloading from the last day where a log file exists
latest_file=$(find ./logs -type f -name "*.log" | sort -r | head -n 1)

if [[ -z "$latest_file" ]]; then
    echo "No log files found. Starting from installation date"
    start_date=$installation_date
else
    day=$(basename $latest_file .log)
    month=$(basename $(dirname $latest_file))
    year=$(basename $(dirname $(dirname $latest_file)))
    start_date="$year-$month-$day"
fi

## Download until today
end_date=$(date +"%Y-%m-%d")

# Define base URL
base_url="https://$senec_host//Log"

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
