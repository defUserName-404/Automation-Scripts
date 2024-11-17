#!/bin/bash

# Associative array to map file categories to their extensions
declare -A filetypes=(
  ["audio"]="mp3 wav"
  ["image"]="jpg jpeg png gif webp svg gif"
  ["video"]="mp4 mov mkv webm wmv"
  ["pdf"]="pdf odf epub"
  ["archive"]="zip tar gz bz2 xz"
  ["package"]="deb rpm flatpakref"
  ["executable"]="exe msi AppImage sh run"
  ["document"]="csv ods xls xlsx txt docx doc ppt pptx"
)

# Function to create necessary directories
create_directories() {
  local base_dir="$1"
  for folder in "${!filetypes[@]}"; do
    mkdir -p "$base_dir/$folder"
  done
  mkdir -p "$base_dir/other"
}

# Function to move folders to "other"
move_directory_to_other() {
  local dir_name="$1"
  local item="$2"
  local base_dir="$3"

  # Remove destination if it already exists
  rm -rf "$base_dir/other/$dir_name"
  mv "$item" "$base_dir/other/"
  echo "Moved folder '$dir_name' to 'other' in $base_dir"
}

# Function to move files based on their extension
move_file_based_on_extension() {
  local file="$1"
  local base_dir="$2"
  local file_ext="${file##*.}"
  local file_moved=false

  # Loop through the filetypes map to find a matching extension
  for category in "${!filetypes[@]}"; do
    extensions="${filetypes[$category]}"
    if [[ " $extensions " == *" $file_ext "* ]]; then
      # If a match is found, move the file to the corresponding category folder
      rm -f "$base_dir/$category/$(basename "$file")"
      mv "$file" "$base_dir/$category/"
      echo "Moved file '$(basename "$file")' to '$category/' in $base_dir"
      file_moved=true
      break
    fi
  done

  # If no matching category is found, move to "other"
  if [[ $file_moved == false ]]; then
    move_file_to_other "$file" "$base_dir"
  fi
}

# Function to move unmatched files to "other"
move_file_to_other() {
  local file="$1"
  local base_dir="$2"
  rm -f "$base_dir/other/$(basename "$file")"
  mv "$file" "$base_dir/other/"
  echo "Moved file '$(basename "$file")' to 'other/' in $base_dir"
}

# Main function to organize the given directory
organize_directory() {
  local base_dir="$1"

  # Check if the directory exists
  if [[ ! -d "$base_dir" ]]; then
    echo "Directory '$base_dir' does not exist. Skipping."
    return
  fi

  # Create necessary directories in the target directory
  create_directories "$base_dir"

  # Organize files and folders
  for item in "$base_dir"/*; do
    local dir_name=$(basename "$item")

    # Skip the "other" folder itself and predefined category folders
    if [[ "$dir_name" == "other" ]] || [[ ${filetypes[$dir_name]+_} ]]; then
      continue
    fi

    # Move directories to "other"
    if [[ -d "$item" ]]; then
      move_directory_to_other "$dir_name" "$item" "$base_dir"
      continue
    fi

    # Move files based on their extension
    if [[ -f "$item" ]]; then
      move_file_based_on_extension "$item" "$base_dir"
    fi
  done

  echo "Organization complete for directory: $base_dir"
}

# Check if at least one directory is passed as an argument
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <directory1> <directory2> ... <directoryN>"
  exit 1
fi

# Process each directory passed as an argument
for target_dir in "$@"; do
  organize_directory "$target_dir"
done

echo "All directories processed!"
