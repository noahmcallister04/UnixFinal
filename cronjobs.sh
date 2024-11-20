#!/bin/bash

#prompts user to select a date using Zenity's calendar picker
selected_date=$(zenity --calendar --title="Select Date" --text="Choose the date to schedule your script" 2>/dev/null)
if [[ -z $selected_date ]]; then
    zenity --error --text="No date selected. Exiting."
    exit 1
fi

#prompts user to select a time in HH:MM format
selected_time=$(zenity --entry --title="Select Time" --text="Enter time in HH:MM format" 2>/dev/null)
if ! [[ $selected_time =~ ^[0-1]?[0-9]:[0-5][0-9]$ ]]; then
    zenity --error --text="Invalid time format. Exiting."
    exit 1
fi

#prompts user to choose AM or PM
am_pm=$(zenity --list --title="AM or PM" --text="Choose AM or PM" --column="Option" "AM" "PM" 2>/dev/null)
if [[ -z $am_pm ]]; then
    zenity --error --text="AM/PM selection is required. Exiting."
    exit 1
fi

#converts 12-hour time to 24-hour time
hour=$(echo "$selected_time" | cut -d: -f1)
minute=$(echo "$selected_time" | cut -d: -f2)
if [[ $am_pm == "PM" && $hour -lt 12 ]]; then
    hour=$((hour + 12))
elif [[ $am_pm == "AM" && $hour -eq 12 ]]; then
    hour=0
fi

#prompts user to select a script file
selected_script=$(zenity --file-selection --title="Select Script File to Schedule" 2>/dev/null)
if [[ -z $selected_script ]]; then
    zenity --error --text="No script file selected. Exiting."
    exit 1
fi

#prompt for repetition schedule
schedule=$(zenity --list --title="Select Repetition Schedule" --text="Choose when the script should run" \
    --column="Schedule" "Once a day" "Once a week" "Once a month" "Once a year" 2>/dev/null)
if [[ -z $schedule ]]; then
    zenity --error --text="No schedule selected. Exiting."
    exit 1
fi

#parses the selected date
day=$(date -d "$selected_date" '+%d')
month=$(date -d "$selected_date" '+%m')
weekday=$(date -d "$selected_date" '+%u')

#determines cron job schedule based on the selected repetition
case $schedule in
    "Once a day")
        cron_schedule="$minute $hour * * *"
        ;;
    "Once a week")
        cron_schedule="$minute $hour * * $weekday"
        ;;
    "Once a month")
        cron_schedule="$minute $hour $day * *"
        ;;
    "Once a year")
        cron_schedule="$minute $hour $day $month *"
        ;;
esac

#add job
crontab -l > temp_cron 2>/dev/null
echo "$cron_schedule $selected_script" >> temp_cron
crontab temp_cron && rm temp_cron

#lil notification for successful scheduled job
zenity --info --text="Cron job scheduled successfully:\n$cron_schedule $selected_script"
