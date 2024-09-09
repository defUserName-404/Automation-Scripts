#!/bin/bash

while true; do
	for file in ~/Downloads/*; do
		if [[ -d "$file" ]]; then
			continue
		fi
		if [[ $file == *.mp3 || $file == *.wav ]]; then
			mkdir -p ~/Downloads/music
			mv "$file" ~/Downloads/music/
		elif [[ $file == *.jpg || $file == *.png || $file == *.jpeg || $file == *.gif || $file == *.webp || $file == *.svg ]]; then
			mkdir -p ~/Downloads/images
			mv "$file" ~/Downloads/images/
		elif [[ $file == *.mp4 || $file == *.mov ]]; then
			mkdir -p ~/Downloads/videos
			mv "$file" ~/Downloads/videos/
		elif [[ $file == *.pdf ]]; then
			mkdir -p ~/Downloads/pdfs
			mv "$file" ~/Downloads/pdfs/
		elif [[ $file == *.zip || $file == *.tar* || $file == *.deb ]]; then
			mkdir -p ~/Downloads/archives
			mv "$file" ~/Downloads/archives/
		elif [[ $file == *.deb ]]; then
			mkdir -p ~/Downloads/packages
			mv "$file" ~/Downloads/packages/
		elif [[ $file == *.exe || $file == *.msi || $file == *.AppImage ]]; then
			mkdir -p ~/Downloads/executables
			mv "$file" ~/Downloads/executables/
		elif [[ $file == *.csv || $file == *.ods || $file == *xls || $file == *.xlsx || $file == *.txt || $file == *.docx || $file == *.doc || $file == *.ppt || $file == *.pptx ]]; then
			mkdir -p ~/Downloads/docs
			mv "$file" ~/Downloads/docs/
		else
			mkdir -p ~/Downloads/others
			mv "$file" ~/Downloads/others
		fi
	done
	# run the command automatically every 60 seconds
	sleep 60
done
