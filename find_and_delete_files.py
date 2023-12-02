#!/usr/bin/env python3


import os
import subprocess
from typing import List, Tuple, Optional


def show_help() -> None:
    print("Usage: {} [OPTIONS]".format(os.path.basename(__file__)))
    print()
    print("OPTIONS:")
    print("--help            Display this help message.")
    print("--file FILE1 FILE2 ...  Specify files to search and delete.")
    print(
        "--directory DIR  Specify the directory to search for files. Default is the current working directory."
    )
    print()
    print("Examples:")
    print(
        "{} --file file1 file2 --directory /path/to/search".format(
            os.path.basename(__file__)
        )
    )
    print("{} file1 /path/to/search".format(os.path.basename(__file__)))


def parse_command_line_arguments() -> Tuple[Optional[str], Optional[List[str]]]:
    directory: str = os.getcwd()
    files: List[str] = []

    i: int = 1
    n: int = len(os.sys.argv)
    print(os.sys.argv)
    while i < n:
        arg: str = os.sys.argv[i]
        if arg == "--help" or n == 1:
            show_help()
            return None, None
        elif arg == "--file":
            i += 1
            while i < n and not os.sys.argv[i].startswith("--"):
                files.append(os.sys.argv[i])
                i += 1
            continue
        elif arg == "--directory":
            i += 1
            directory = os.sys.argv[i]
        else:
            if n == 1:
                show_help()
                return None, None
            elif n == 2:
                files.append(arg)
            elif n == 3:
                files.append(arg)
                directory = os.sys.argv[i + 1]
            break
        i += 1

    return directory, files


def find_and_print_files(directory: str, files: List[str]) -> List[str]:
    found_files: List[str] = []

    for pattern in files:
        # Use os.path.join to construct the full path of the directory
        find_command: str = (
            f'find {os.path.join(directory, "")} -type f -iname "*{pattern}*"'
        )
        # Check if the script is running with sudo
        if os.geteuid() == 0:
            find_command = f"sudo {find_command}"
        print(find_command)
        try:
            # Use subprocess to run the find command
            result: subprocess.CompletedProcess[str] = subprocess.run(
                find_command, shell=True, check=True, text=True, capture_output=True
            )
            found_files.extend(result.stdout.splitlines())
        except subprocess.CalledProcessError as e:
            print(f"Error running find command: {e}")

    return found_files


def delete_files(directory: str, found_files: List[str]) -> None:
    if not found_files:
        print("No matching files found in the specified directory.")
        return

    print("Found the following files:")
    for file in found_files:
        print(file)

    confirm: str = input("Do you want to proceed with the deletion? (y/n): ").lower()

    if confirm == "y":
        for file in found_files:
            try:
                # Use sudo if the script is running with root privileges
                if os.geteuid() == 0:
                    subprocess.run(["sudo", "rm", "-i", file], check=True)
                else:
                    os.remove(file)
                    print(f"Deleted: {os.path.join(directory, file)}")
            except FileNotFoundError:
                print(f"File not found: {os.path.join(directory, file)}")
            except Exception as e:
                print(f"Error deleting {os.path.join(directory, file)}: {e}")
        print("Files deleted successfully.")
    elif confirm == "n":
        print("Deletion canceled by the user.")
    else:
        print("Invalid input. Please enter 'y' or 'n'.")


def main() -> None:
    directory: Optional[str]
    files: Optional[List[str]]
    directory, files = parse_command_line_arguments()
    if directory is None or files is None:
        return

    found_files: List[str] = find_and_print_files(directory, files)

    delete_files(directory, found_files)


if __name__ == "__main__":
    main()
