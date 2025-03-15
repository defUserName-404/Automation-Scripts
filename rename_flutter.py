import os
import sys


def swap_flutter_folders(directory):
	flutter_29 = os.path.join(directory, "flutter-29")
	flutter_27 = os.path.join(directory, "flutter-27")
	flutter = os.path.join(directory, "flutter")
	temp_name = os.path.join(directory, "flutter-temp")

	if os.path.exists(flutter_29) and os.path.exists(flutter):
		print("Swapping 'flutter-29' with 'flutter'")
		os.rename(flutter, temp_name)
		os.rename(flutter_29, flutter)
		os.rename(temp_name, flutter_27)
	elif os.path.exists(flutter_27) and os.path.exists(flutter):
		print("Swapping 'flutter-27' with 'flutter'")
		os.rename(flutter, temp_name)
		os.rename(flutter_27, flutter)
		os.rename(temp_name, flutter_29)
	else:
		print("Required folders not found. Make sure 'flutter-29' and 'flutter' or 'flutter-27' and 'flutter' exist.")


if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("Usage: python swap_flutter_folders.py <directory>")
		sys.exit(1)

	target_directory = sys.argv[1]
	if not os.path.isdir(target_directory):
		print("Invalid directory path.")
		sys.exit(1)

	swap_flutter_folders(target_directory)
