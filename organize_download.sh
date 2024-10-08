#!/bin/bash

# Associative array to map file categories to their extensions
declare -A filetypes=(
    ["audio"]="mp3 wav"
    ["image"]="jpg jpeg png gif webp svg"
    ["video"]="mp4 mov mkv webm wmv"
    ["pdf"]="pdf odf epub"
    ["archive"]="zip tar gz bz2 xz"
    ["package"]="deb rpm flatpakref"
    ["executable"]="exe msi AppImage"
    ["document"]="csv ods xls xlsx txt docx doc ppt pptx"
)

# Base directory to organize
base_dir=~/Downloads

# Function to create necessary directories
create_directories() {
    for folder in "${!filetypes[@]}"; do
        mkdir -p "$base_dir/$folder"
    done
    mkdir -p "$base_dir/other"
}

# Function to move folders to "other"
move_directory_to_other() {
    local dir_name=$1
    local item=$2

    # Remove destination if it already exists
    rm -rf "$base_dir/other/$dir_name"
    mv "$item" "$base_dir/other/"
    echo "Moved folder '$dir_name' to 'other'"
}

# Function to move files based on their extension
move_file_based_on_extension() {
    local file=$1
    local file_ext="${file##*.}"
    local file_moved=false

    # Loop through the filetypes map to find a matching extension
    for category in "${!filetypes[@]}"; do
        extensions="${filetypes[$category]}"
        if [[ " $extensions " == *" $file_ext "* ]]; then
            # If a match is found, move the file to the corresponding category folder
            rm -f "$base_dir/$category/$(basename "$file")"
            mv "$file" "$base_dir/$category/"
            echo "Moved file '$(basename "$file")' to '$category/'"
            file_moved=true
            break
        fi
    done

    # If no matching category is found, move to "other"
    if [[ $file_moved == false ]]; then
        move_file_to_other "$file"
    fi
}

# Function to move unmatched files to "other"
move_file_to_other() {
    local file=$1
    rm -f "$base_dir/other/$(basename "$file")"
    mv "$file" "$base_dir/other/"
    echo "Moved file '$(basename "$file")' to 'other/'"
}

# Main function to organize the Downloads folder
organize_downloads_folder() {
    for item in "$base_dir"/*; do
        local dir_name=$(basename "$item")

        # Skip the "other" folder itself and predefined category folders
        if [[ "$dir_name" == "other" ]] || [[ ${filetypes[$dir_name]+_} ]]; then
            continue
        fi

        # Move directories to "other"
        if [[ -d "$item" ]]; then
            move_directory_to_other "$dir_name" "$item"
            continue
        fi

        # Move files based on their extension
        if [[ -f "$item" ]]; then
            move_file_based_on_extension "$item"
        fi
    done
}

# Create directories and run the main organization function
create_directories
organize_downloads_folder

echo "File and folder organization complete!"
