#!/bin/bash

# Define paths
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
THEME_CSS="$HOME/.config/waybar/theme.css"  # Correct path

# Fetch the background image from swww and strip the 'image:' prefix
BACKGROUND_IMAGE=$(swww query | grep -oP 'currently displaying: image: \K.*')
if [ -z "$BACKGROUND_IMAGE" ] || [ ! -f "$BACKGROUND_IMAGE" ]; then
    echo "No valid background image found from swww."
    exit 1
fi

# Extract colors from theme.css
FG_COLOR=$(grep '@define-color main-fg' "$THEME_CSS" | awk '{print $3}' | tr -d ';')
BG_COLOR=$(grep '@define-color main-bg' "$THEME_CSS" | awk '{print $3}' | tr -d ';')
TEXT_COLOR=$(grep '@define-color wb-act-fg' "$THEME_CSS" | awk '{print $3}' | tr -d ';')
BAR_BG=$(grep '@define-color wb-act-fg' "$THEME_CSS" | awk '{print $3}' | tr -d ';')

# Check if colors were extracted successfully
if [ -z "$FG_COLOR" ] || [ -z "$BG_COLOR" ] || [ -z "$TEXT_COLOR" ]; then
    echo "Error: Failed to extract colors from $THEME_CSS. Please check the file."
    exit 1
fi

# Get the hostname and username
HOSTNAME=$(hostname)
USERNAME=$(whoami)

# Create the hyprlock config
cat <<EOL > "$HYPRLOCK_CONF"
# hyprlock.conf

# Background widget (modern, with slight blur)
background {
    monitor =
    path = $BACKGROUND_IMAGE
    color = rgba(30, 30, 30, 0.8)
    blur_passes = 2
    blur_size = 8
    noise = 0.01
    contrast = 0.9
    brightness = 0.8
    vibrancy = 0.2
    vibrancy_darkness = 0.1
}

# Label widget for hostname@username
label {
    monitor =
    text = $HOSTNAME@$USERNAME
    text_align = center
    color = $FG_COLOR
    font_size = 40
    font_family = "Noto Sans"
    shadow_passes = 3
    shadow_size = 5
    shadow_color = rgba(0, 0, 0, 0.5)
    shadow_boost = 1.5
    position = 0, 90  # Adjusted position to sit above the input field
    halign = center
    valign = center
}

# Input Field widget (password input)
input-field {
    monitor =
    size = 300, 60
    outline_thickness = 4
    dots_size = 0.4
    dots_rounding = -1
    inner_color = $BG_COLOR
    outer_color = $FG_COLOR
    font_color = $FG_COLOR
    placeholder_text = <i>Enter password...</i>
    fade_on_empty = true
    fade_timeout = 1500
    position = 0, -10  # Adjust position for better alignment
    halign = center
    valign = center
    # shadow_passes = 3
    # shadow_size = 3
    # shadow_color = rgba(0, 0, 0, 0.4)
}

# Shape widget for a modern divider line
shape {
    monitor =
    size = 400, 2
    color = rgba(255, 255, 255, 0.5)
    rounding = 0
    position = 0, 50  # Adjust position for the divider line
    halign = center
    valign = center
    shadow_passes = 2
    shadow_size = 3
    shadow_color = rgba(0, 0, 0, 0.3)
}

# Label widget for authentication failed message (hidden by default)
# label {
#     monitor =
#     text = Authentication Failed
#     text_align = center
#     color = "#cc2222"  # Red color for error message
#     font_size = 25
#     font_family = "Noto Sans"
#     position = 0, 70  # Adjust position below the input field
#     halign = center
#     valign = center
#     visible = false  # Initially hidden
#     fade_on_empty = true
# }
EOL

echo "Background Image: $BACKGROUND_IMAGE"
echo "Hyprlock config updated successfully with modern hostname@username display."
hyprlock 