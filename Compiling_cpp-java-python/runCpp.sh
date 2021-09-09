#!/bin/bash

# Filename passed in as argument
fileName=$1

# Color Codes
BLUE='\033[1;34m'
YELLOW='\033[1;33m'

# Absolute path to the file
DIR=$(dirname $(readlink -f "$fileName"))

# Absolute path to the binary files
DIR_OUT="$DIR"/out

execute() {
    echo "${BLUE}"
    ./$fileName.out
}

compile() {
    echo "${YELLOW}Compiling..."
    g++ -std=c++17 $fileName.cpp -o $fileName.out
    echo "Done!"
    execute
    # move the bin file to the output directory
    mv *.out "$DIR_OUT"
}

execute_bin() {
    echo "${BLUE}"
    cd "$DIR_OUT" 
    execute
}

add_or_delete_lines() {
    if [ "$1" = "add" ] 
    then
        # Adding these lines to the cpp file
        sed -i '2i#define LOCAL_DEBUG_IN' $fileName.cpp
        sed -i '3i#define LOCAL_DEBUG_OUT' $fileName.cpp
    else
        # Deleting the lines
        sed -i '2,3d' $fileName.cpp
    fi
}

do_stuff() {
    add_or_delete_lines "add"
    compile
    add_or_delete_lines "dlt"
}

# If bin folder doesn't exist, create one and compile the cpp file
# If it exists, check it has been compiled already or not
# If it's already compiled just execute the bin file, compile and execute otherwise
if [ -d "$DIR_OUT" ]
then
    if [ -f "$DIR_OUT"/"$fileName".out ]
    then
        execute_bin
    else
        do_stuff
    fi
else
    mkdir "$DIR_OUT"
    do_stuff
fi

echo '\n'