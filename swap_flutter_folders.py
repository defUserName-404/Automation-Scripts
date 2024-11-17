#!/usr/bin/python3

import os
import sys


def swap_flutter_folders(directory):
	flutter_29 = os.path.join(directory, "flutter-29")
	flutter_27 = os.path.join(directory, "flutter-27")
	flutter = os.path.join(directory, "flutter")
	temp_name = os.path.join(directory, "flutter-temp")

	if os.path.exists(flutter_29) and os.path.exists(flutter):
		print("Making flutter version 29 the default")
		os.rename(flutter, temp_name)
		os.rename(flutter_29, flutter)
		os.rename(temp_name, flutter_27)
	elif os.path.exists(flutter_27) and os.path.exists(flutter):
		print("Making flutter version 27 the default")
		os.rename(flutter, temp_name)
		os.rename(flutter_27, flutter)
		os.rename(temp_name, flutter_29)
	else:
		print("Required folders not found. Make sure 'flutter-29' and 'flutter' or 'flutter-27' and 'flutter' exist.")



if __name__ == "__main__":
	target_directory = sys.argv[1]
	if not os.path.isdir(target_directory):
		print("Invalid directory path.")
		sys.exit(1)

	swap_flutter_folders(target_directory)
