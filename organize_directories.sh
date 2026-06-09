#!/bin/zsh

# associative array mapping file categories to extensions
typeset -A filetypes
filetypes=(
  audio      "mp3 wav m4a flac aac ogg wma alac mid midi m4r aif"
  image      "jpg jpeg png gif webp svg tiff tif bmp ico heic heif raw cr2 nef dng psd"
  video      "mp4 mov mkv webm wmv avi flv m4v mpg mpeg 3gp srt"
  archive    "zip tar gz bz2 xz rar 7z sitx iso img dmg"
  package    "deb rpm flatpakref snap appx msix bundles apk aab ipa ipsw pkg"
  executable "exe msi AppImage sh run bat cmd com jar ps1 bin elf command"
  document   "pdf csv ods xls xlsx txt docx doc ppt pptx md htm html epub odf rtf pages numbers key log"
  notebook   "ipynb qmd rmd"
  code       "py js ts tsx jsx html css scss sass c cpp h hpp cs java go rs rb php kt kts swift m mm pl pm r sh bash zsh fish sql json xml yaml yml ini conf toml gradle properties bak patch diff"
)

# Function to create necessary directories
create_directories() {
  local base_dir="$1"
  for folder in ${(k)filetypes}; do
    mkdir -p "$base_dir/$folder"
  done
  mkdir -p "$base_dir/other"
}

# Function to move folders to "other"
move_directory_to_other() {
  local dir_name="$1"
  local item="$2"
  local base_dir="$3"

  rm -rf "$base_dir/other/$dir_name"
  mv "$item" "$base_dir/other/"
  echo "Moved folder '$dir_name' to 'other' in $base_dir"
}

# Function to move files based on their extension
move_file_based_on_extension() {
  local file="$1"
  local base_dir="$2"
  local file_ext="${file:e}" # Zsh modifier to easily grab file extension
  local file_moved=false

  # Convert extension to lowercase for reliable matching
  file_ext="${file_ext:l}"

  # Loop through keys to find a matching extension
  for category in ${(k)filetypes}; do
    extensions="${filetypes[$category]}"
    # Check if extension exists as a word in the string
    if [[ " $extensions " == *" $file_ext "* ]]; then
      rm -f "$base_dir/$category/${file:t}"
      mv "$file" "$base_dir/$category/"
      echo "Moved file '${file:t}' to '$category/' in $base_dir"
      file_moved=true
      break
    fi
  done

  if [[ $file_moved == false ]]; then
    move_file_to_other "$file" "$base_dir"
  fi
}

# Function to move unmatched files to "other"
move_file_to_other() {
  local file="$1"
  local base_dir="$2"
  rm -f "$base_dir/other/${file:t}"
  mv "$file" "$base_dir/other/"
  echo "Moved file '${file:t}' to 'other/' in $base_dir"
}

# Main function to organize the given directory
organize_directory() {
  local base_dir="$1"

  if [[ ! -d "$base_dir" ]]; then
    echo "Directory '$base_dir' does not exist. Skipping."
    return
  fi

  create_directories "$base_dir"

  # Zsh loop avoiding word-splitting errors on spaces
  for item in "$base_dir"/*(N); do
    # Skip if the directory is empty and glob expands to nothing
    [[ -e "$item" ]] || continue
    
    local dir_name="${item:t}" # Zsh shortcut for basename

    # Skip the "other" folder itself and predefined category folders
    if [[ "$dir_name" == "other" ]] || [[ -n "${filetypes[$dir_name]}" ]]; then
      continue
    fi

    # Handle macOS .app bundles as packages instead of raw directories
    if [[ -d "$item" && "$dir_name" == *.app ]]; then
      rm -rf "$base_dir/package/$dir_name"
      mv "$item" "$base_dir/package/"
      echo "Moved macOS App Bundle '$dir_name' to 'package/'"
      continue
    fi

    # Move directories to "other"
    if [[ -d "$item" ]]; then
      move_directory_to_other "$dir_name" "$item" "$base_dir"
      continue
    fi

    # Move files based on extension
    if [[ -f "$item" ]]; then
      move_file_based_on_extension "$item" "$base_dir"
    fi
  done

  echo "Organization complete for directory: $base_dir"
}

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <directory1> <directory2> ... <directoryN>"
  exit 1
fi

for target_dir in "$@"; do
  organize_directory "$target_dir"
done

echo "All directories processed!"
