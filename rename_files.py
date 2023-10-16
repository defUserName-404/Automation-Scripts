#!/usr/bin/env python3

import os
import sys
import re

# * This script renames all the files in a specific folder
# * by removing _-+=,!@#$%^&*().?'"\

def rename_files(directory):
    for root, _, files in os.walk(directory):
        for filename in files:
            file_path = os.path.join(root, filename)

            name, extension = os.path.splitext(filename)
            new_name = re.sub(r'[_\-+=,!@#$%^&*()\.\?\'\"\\]', ' ', name).strip()

            if new_name:
                new_name = new_name + extension
                new_path = os.path.join(root, new_name)
                os.rename(file_path, new_path)
                print(f"Renamed: {file_path} to {new_name}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python rename_files.py <directory>")
    else:
        directory = sys.argv[1]
        rename_files(directory)
