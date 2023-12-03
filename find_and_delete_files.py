#!/usr/bin/env python3


from enum import Enum
import os
import shutil
import subprocess
from typing import List, Tuple, Optional


class User_Type(Enum):
    ROOT = 0
    REGULAR_USER = 1


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
    args: List[str] = os.sys.argv
    i: int = 1
    n: int = len(args)

    while i < n:
        arg: str = args[i]
        if arg == "--help" or arg == "-h":
            show_help()
            return None, None
        elif arg == "--file" or arg == "-f":
            i += 1
            while i < n and not (args[i].startswith("--") or args[i].startswith("-")):
                files.append(args[i])
                i += 1
            continue
        elif arg == "--directory" or arg == "-d":
            i += 1
            directory = args[i]
        else:
            if n == 1:
                show_help()
                return None, None
            elif n == 2:
                files.append(arg)
            elif n == 3:
                files.append(arg)
                directory = args[-1]
            break
        i += 1

    return directory, files


def find_and_print_files(
    directory: str, files: List[str], user_type: User_Type
) -> List[str]:
    found_files: List[str] = []

    for pattern in files:
        # Use os.path.join to construct the full path of the directory
        find_command: str = f'find {os.path.join(directory, "")} -iname "*{pattern}*"'
        # Check if the script is running with sudo
        if user_type == User_Type.ROOT:
            find_command = f"sudo {find_command}"
        try:
            # Use subprocess to run the find command
            result: subprocess.CompletedProcess[str] = subprocess.run(
                find_command, shell=True, check=True, text=True, capture_output=True
            )
            found_files.extend(result.stdout.splitlines())
        except subprocess.CalledProcessError as e:
            print(f"Error running find command: {e}")

    return found_files


def delete_files(directory: str, found_files: List[str], user_type: User_Type) -> None:
    if not found_files:
        print("No matching files or directories found in the specified directory.")
        return

    print("Found the following files and directories:")
    for item in found_files:
        print(item)

    confirm: str = input("Do you want to proceed with the deletion? (y/n): ").lower()

    if confirm == "y":
        for item in found_files:
            full_path = os.path.join(directory, item)

            try:
                # Use sudo if the script is running with root privileges
                if user_type == User_Type.ROOT:
                    subprocess.run(["sudo", "rm", "-r", "-i", full_path], check=True)
                else:
                    if os.path.isdir(full_path):
                        shutil.rmtree(full_path)
                    else:
                        os.remove(full_path)

                    print(f"Deleted: {full_path}")

            except FileNotFoundError:
                print(f"File or directory not found: {full_path}")
            except Exception as e:
                print(f"Error deleting {full_path}: {e}")

        print("Files and directories deleted successfully.")
    elif confirm == "n":
        print("Deletion canceled by the user.")
    else:
        print("Invalid input. Please enter 'y' or 'n'.")


def get_user_type(userid) -> User_Type:
    return User_Type.ROOT if userid == 0 else User_Type.REGULAR_USER


def main() -> None:
    directory: Optional[str]
    files: Optional[List[str]]
    user_type: User_Type = get_user_type(os.geteuid())

    directory, files = parse_command_line_arguments()
    if directory is None or files is None:
        return

    found_files: List[str] = find_and_print_files(directory, files, user_type)

    delete_files(directory, found_files, user_type)


if __name__ == "__main__":
    main()
