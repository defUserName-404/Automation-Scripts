#!/bin/bash

# Filename passed in as argument. Flag is used for recompilation.
fileName=$1
flag=$2

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

# To handle case when we need to recompile and run the file, we will check the flag
# If bin folder doesn't exist, create one and compile the cpp file
# If it exists, check it has been compiled already or not
# If it's already compiled just execute the bin file, compile and execute otherwise
if [ "$flag" = "recompile" ]
then
    rm -r out/"$fileName".*
    compile
else
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
fi

# To shift focus back to the editor
xdotool key Control_L+period

echo '\n'