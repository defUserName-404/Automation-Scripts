#!/bin/bash

# Filename passed in as argument.
fileName=$1

# Color codes
BLUE='\033[1;34m'
YELLOW='\033[1;33m'

# Absolute path to the file
DIR="$(dirname "$(readlink -f "$fileName")")"

# Absolute path to the binary files
DIR_OUT="$DIR"/out

compile() {
    javac "$fileName".java && echo "${YELLOW}Compiling..."
    echo "Done!"
    echo "${BLUE}"
    java "$fileName"
    mv *.class "$DIR_OUT"
}

execute_bin() {
    echo "${BLUE}"
    cd "$DIR_OUT"
    java "$fileName"
    cd "$DIR"
}

# If bin folder doesn't exist, create one and compile the cpp file
# If it exists, check it has been compiled already or not
# If it's already compiled just execute the bin file, compile and execute otherwise
if [ -d "$DIR_OUT" ]
then
    if [ -f "$DIR_OUT"/"$fileName".class ]
    then
        execute_bin
    else
        compile
    fi
else
    mkdir "$DIR_OUT"
    compile
fi

echo '\n'