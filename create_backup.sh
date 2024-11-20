#!/bin/bash

# Function to display an error message and exit
function error_exit {
    zenity --error --text="$1"
    exit 1
}

# Select a source directory using Zenity
SOURCE=$(zenity --file-selection --directory --title="Select the source folder")
if [ $? -ne 0 ]; then
    error_exit "Source folder selection canceled."
fi

# Select a destination directory using Zenity
DESTINATION=$(zenity --file-selection --directory --title="Select the destination folder")
if [ $? -ne 0 ]; then
    error_exit "Destination folder selection canceled."
fi

# Create a backup file name based on the current date
BACKUP_NAME="backup_$(date +%Y%m%d%H%M%S).tar.gz"

# Create the backup using tar
tar -czf "$DESTINATION/$BACKUP_NAME" -C "$SOURCE" .
if [ $? -eq 0 ]; then
    zenity --info --text="Backup successful! File saved as $DESTINATION/$BACKUP_NAME"
else
    error_exit "Backup failed. Please check your source and destination folders."
fi
