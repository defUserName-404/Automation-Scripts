#!/bin/bash

# Check if at least three arguments are provided
if [ "$#" -lt 3 ]; then
	echo "Usage: $0 <command> <destination> <file1> [file2 ... fileN]"
	echo "Commands: mv (move), cp (copy), rm (remove), touch (create files)"
	exit 1
fi

# Assign the first argument to COMMAND
COMMAND=$1

# Assign the second argument to DESTINATION
DESTINATION=$2

# Remaining arguments are file names
FILES="${@:3}"

# Validate the command
if [[ "$COMMAND" != "mv" && "$COMMAND" != "cp" && "$COMMAND" != "rm" && "$COMMAND" != "touch" ]]; then
	echo "Error: Unsupported command '$COMMAND'. Use 'mv', 'cp', 'rm', or 'touch'."
	exit 1
fi

if [ ! -d "$DESTINATION" ]; then
	echo "Error: Destination '$DESTINATION' is not a valid directory."
	exit 1
fi

# Loop through the files and validate existence where needed
for FILE in $FILES; do
	# Prepend destination path for 'touch'
	if [[ "$COMMAND" == "touch" ]]; then
		TARGET_FILE="$DESTINATION/$FILE"
	else
		TARGET_FILE="$FILE"
	fi

	# For commands other than touch, validate existence
	if [[ "$COMMAND" != "touch" && ! -e "$FILE" ]]; then
		echo "Warning: File '$FILE' does not exist. Skipping."
		continue
	fi

	# Execute the command based on the case
	case $COMMAND in
	rm)
		echo "Deleting $FILE"
		rm "$FILE"
		;;
	mv)
		echo "Moving $FILE -> $DESTINATION"
		mv "$FILE" "$DESTINATION"
		;;
	cp)
		echo "Copying $FILE -> $DESTINATION"
		cp "$FILE" "$DESTINATION"
		;;
	touch)
		echo "Creating file $TARGET_FILE"
		touch "$TARGET_FILE"
		;;
	esac
done

echo "Operation completed."
