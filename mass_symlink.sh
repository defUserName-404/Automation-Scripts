#!/bin/bash

# Function to print the help message
help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s, --source <dir>     Source directory to create symlinks from (default: current working directory)"
    echo "  -d, --destination <dir> Destination directory to create symlinks in (default: $HOME)"
    echo "  -h, --help               Display this help message"
    echo "Creates symlinks for files with supported extensions (.out, .class, .bin, .py, .sh) from the specified source directory to the destination directory."
}

# Initialize variables
source_dir=""
destination_dir=""
longopts="source:,destination:,help"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            source_dir="$2"
            shift 2
            ;;
        -d|--destination)
            destination_dir="$2"
            shift 2
            ;;
        -h|--help)
            help
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            help
            exit 1
            ;;
    esac
done

# Check if source directory is specified
if [[ -z "$source_dir" ]]; then
    echo "No source directory specified. Creating symlinks from current working directory. Continue? (y/n)"
    read -r confirm
    if [[ $confirm != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
    source_dir=$(pwd)
fi

# Check if destination directory is specified
if [[ -z "$destination_dir" ]]; then
    echo "No destination directory specified. Creating symlinks in $HOME. Continue? (y/n)"
    read -r confirm
    if [[ $confirm != "y" ]]; then
        echo "Aborting."
        exit 1
    fi
    destination_dir="$HOME"
fi

# Check if source directory exists
if [[ ! -d "$source_dir" ]]; then
    echo "Error: Source directory '$source_dir' does not exist."
    exit 1
fi

# Check if destination directory exists
if [[ ! -d "$destination_dir" ]]; then
    echo "Error: Destination directory '$destination_dir' does not exist."
    exit 1
fi

# Check if source and destination directories are the same
if [[ "$source_dir" == "$destination_dir" ]]; then
    echo "Error: Source and destination directories cannot be the same."
    exit 1
fi

# Supported extensions
extensions=(.out .class .bin .py .sh)

# Create symlinks for files with supported extensions
for file in "$source_dir"/*; do
    if [[ -f "$file" ]]; then
        # Extract the filename and extension
        filename=$(basename "$file")
        base_name="${filename%.*}"
        extension="${filename##*.}"

        if [[ "$base_name" == "$filename" ]]; then
            echo "Skipped '$file': no extension."
        fi

        if [[ " ${extensions[@]} " =~ " .$extension " ]]; then
            symlink_path="$destination_dir/$base_name"
            if [[ ! -e "$symlink_path" ]]; then
                ln -s "$file" "$symlink_path"
                echo "Created symlink from '$file' to '$symlink_path'"
            else
                echo "Symlink already exists: '$symlink_path'"
            fi
        else
            echo "Skipped '$file': unsupported extension."
        fi
    fi
	# Extract the directory name
	if [[ -d "$file" ]]; then
		dir_name=$(basename "$file")
		symlink_path="$destination_dir/$dir_name"
		if [[ ! -e "$symlink_path" ]]; then
			ln -s "$file" "$symlink_path"
			echo "Created symlink from directory '$file' to '$symlink_path'"
		else
			echo "Symlink already exists for directory: '$symlink_path'"
		fi
	fi
done
