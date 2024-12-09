#!/bin/bash

# Name the script `cargo-update-all`

# Extract the list of installed Cargo binaries and reinstall them
cargo install $(cargo install --list | egrep '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')
