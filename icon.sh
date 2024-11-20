#!/bin/bash

#prompts user to select a script
script_file=$(zenity --file-selection --title="Select a Script to Run" --file-filter="*.sh")
if [ -z "$script_file" ]; then
    zenity --error --text="No script selected. Exiting."
    exit 1
fi

#prompts user to select image
icon_file=$(zenity --file-selection --title="Select an Icon Image" --file-filter="Images (png, jpg, jpeg) | *.png *.jpg *.jpeg")
if [ -z "$icon_file" ]; then
    zenity --error --text="No image selected. Exiting."
    exit 1
fi

#prompts user to enter name for the desktop icon
desktop_name=$(zenity --entry --title="Enter a Name for the Desktop Icon" --text="Enter the name for your desktop shortcut:")
if [ -z "$desktop_name" ]; then
    desktop_name="CustomShortcut" # Default name
fi

#defines path for the .desktop file for the user's desktop
desktop_path="$HOME/Desktop/$desktop_name.desktop"

#creates .desktop file
cat > "$desktop_path" <<EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=$desktop_name
Exec=$script_file
Icon=$icon_file
Terminal=true
EOL

#makes the desktop file executable
chmod +x "$desktop_path"

#notification that the desktop shortcut has been created
zenity --info --text="The desktop shortcut '$desktop_name' has been created and added to your desktop."
