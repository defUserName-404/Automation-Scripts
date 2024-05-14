#!/bin/bash

# Get the package ID from the second-to-last line of apt history
package_id=$(sudo nala history | tail -n 2 | head -n 1 | awk '{print $1}')

# Undo the package change
echo 'Undoing the last change from apt history'
sudo nala history undo "$package_id"
