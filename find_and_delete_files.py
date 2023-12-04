#!/usr/bin/env python3


import argparse
from enum import Enum
import os
import shutil
import subprocess
import sys
from typing import List, NoReturn, Tuple, Optional, Dict


class User_Type(Enum):
    ROOT = 0
    REGULAR_USER = 1


class CustomArgumentParser(argparse.ArgumentParser):
    error_occurred = False

    def error(self, message) -> NoReturn:
        CustomArgumentParser.error_occurred = True
        print_colored_text(f"Error: {message}", "red")
        self.print_custom_help()
        self.exit(2)

    def exit(self, status=0, message=None) -> None:
        if message:
            print_colored_text(message, "red")
        if CustomArgumentParser.error_occurred:
            sys.exit(status)
        else:
            raise SystemExit

    def print_custom_help(self) -> None:
        print_colored_text(
            "\nFind matching files in a directory and delete them.\n", "blue"
        )
        print_colored_text(
            f"Usage: {os.path.basename(__file__)} [options]\nOptions:", "purple"
        )
        options: str = "  -d, --directory   Specify the directory\n"
        options += "  -f, --file        Specify one or more files\n"
        options += "  -e, --exact       Use exact file names\n"
        options += "  -i, --case-insensitive  Perform case-insensitive matching\n"
        options += "  -h, --help Display the help text\n"
        print_colored_text(options, "blue")
        print_colored_text(
            f"Positional Arguments: {os.path.basename(__file__)} [arguments]\nArguments:",
            "purple",
        )
        arguments: str = "  FILE	The FILE to be searched\n  FILE DIRECTORY	The FILE IN the DIRECTORY to be searched\n"
        print_colored_text(arguments, "blue")
        print_colored_text("Example Usages:", "purple")
        examples: str = f"{os.path.basename(__file__)} --file file1 file2 ... --directory /path/to/search"
        examples += f"\n{os.path.basename(__file__)} --file file1 -ie"
        examples += f"\n{os.path.basename(__file__)} --file file1 --directory /path/to/search --exact --case-insensitive"
        examples += f"\n{os.path.basename(__file__)} file"
        examples += f"\n{os.path.basename(__file__)} file /path/to/search"
        print_colored_text(examples, "yellow")


def print_colored_text(text: str, color: str) -> str:
    colors: Dict[str, str] = {
        "red": "\033[91m",
        "green": "\033[92m",
        "yellow": "\033[93m",
        "blue": "\033[94m",
        "purple": "\033[95m",
        "reset": "\033[0m",
    }
    print(f"{colors[color]}{text}{colors['reset']}\n", end="")


def parse_command_line_arguments() -> (
    Tuple[Optional[str], Optional[List[str]], bool, bool]
):
    parser = CustomArgumentParser(
        description="Find matching files in a directory and delete them"
    )

    if (
        len(sys.argv) == 1
        or CustomArgumentParser.error_occurred
        or "--help" in sys.argv
        or "-h" in sys.argv
    ):
        parser.print_custom_help()
        sys.exit(2)

    # Check the number of arguments
    if len(sys.argv) == 2:
        # Case: Only one argument, treat it as a file
        parser.add_argument("file", help="Specify the file")
        args: argparse.Namespace = parser.parse_args()
        return os.getcwd(), [args.file], False, False
    elif len(sys.argv) == 3:
        # Case: Two arguments, treat the first as a file and the second as a directory
        parser.add_argument("file", help="Specify the file")
        parser.add_argument("directory", help="Specify the directory")
        args: argparse.Namespace = parser.parse_args()
        return args.directory, [args.file], False, False
    else:
        parser.add_argument(
            "--directory",
            "-d",
            type=str,
            default=os.getcwd(),
            help="Specify the directory",
        )
        parser.add_argument("--file", "-f", nargs="+", help="Specify one or more files")
        parser.add_argument(
            "--exact", "-e", action="store_true", help="Use exact file names"
        )
        parser.add_argument(
            "--case-insensitive",
            "-i",
            action="store_true",
            help="Perform case-insensitive matching",
        )
        args: argparse.Namespace = parser.parse_args()
        return args.directory, args.file, args.exact, args.case_insensitive


def find_and_print_files(
    directory: str,
    files: List[str],
    user_type: User_Type,
    is_exact_file_name: bool,
    is_case_sensitive: bool,
) -> List[str]:
    found_files: List[str] = []
    # Use os.path.join to construct the full path of the directory
    full_directory: str = os.path.join(directory, "")
    # Create a list of patterns for the find command
    patterns: List[str] = []
    for pattern in files:
        if is_exact_file_name:
            patterns.append(f"-name '{pattern}'")
        elif is_case_sensitive:
            patterns.append(f"-name '{pattern}'")
        else:
            patterns.append(f"-iname '*{pattern}*'")

    # Construct the find command
    find_command: str = f"find {full_directory} {' -o '.join(patterns)}"

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

    if not found_files:
        print_colored_text(
            "No matching files or directories found in the specified directory.", "red"
        )
        return

    print("Found the following files and directories:")
    for item in found_files:
        print_colored_text(item, "yellow")

    return found_files


def delete_files(directory: str, found_files: List[str], user_type: User_Type) -> None:
    confirm: str = input("Do you want to proceed with the deletion? (y/n): ").lower()

    if confirm == "y":
        for item in found_files:
            full_path: str = os.path.join(directory, item)

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

        print_colored_text("Files and directories deleted successfully.", "green")
    elif confirm == "n":
        print_colored_text("Deletion cancelled by the user.", "red")
    else:
        print_colored_text("Invalid input. Please enter 'y' or 'n'.", "red")


def get_user_type(userid) -> User_Type:
    return User_Type.ROOT if userid == 0 else User_Type.REGULAR_USER


def main() -> None:
    directory: Optional[str]
    files: Optional[List[str]]
    is_exact: bool
    is_case_sensitive: bool
    user_type: User_Type = get_user_type(os.geteuid())
    directory, files, is_exact, is_case_sensitive = parse_command_line_arguments()

    if directory is None or files is None:
        return

    found_files: List[str] = find_and_print_files(
        directory, files, user_type, is_exact, is_case_sensitive
    )
    if found_files is not None:
        delete_files(directory, found_files, user_type)


if __name__ == "__main__":
    main()
