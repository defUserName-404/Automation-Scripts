#!/bin/bash

# Automatically deletes the zsh history every 5 minutes
while true; do
	cat -n $HOME/.zsh_history | sort -t ';' -uk2 | sort -nk1 | cut -f2- > $HOME/.zsh_short_history
	mv $HOME/.zsh_short_history $HOME/.zsh_history

	sleep 300
done