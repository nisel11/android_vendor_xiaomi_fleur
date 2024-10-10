#!/bin/bash

# Paths
SEA_DIR=$PWD/vendor-sea
FLEUR_SRC_DIR=$PWD/vendor-fleur
FLEUR_DEST_DIR=$PWD/vendorz
MISSING_LOG=missing.txt

# File lists
P_FILES_TXT=pfiles-sea.txt
P_FILES_FLEUR_TXT=pfiles-fleur.txt

# Clear previous missing file log
> "$MISSING_LOG"

# Function to copy files and create subdirectories if needed
copy_file_with_subdirs() {
  src_dir=$1
  dest_dir=$2
  src_file=$3
  dest_file=$4
  
  # Ensure the destination directory exists
  dest_subdir=$(dirname "$dest_dir/$dest_file")
  mkdir -p "$dest_subdir"
  
  # Copy the file
  cp "$src_dir/$src_file" "$dest_dir/$dest_file"
}

# Function to process a line from a file list
process_line() {
  local src_dir=$1
  local dest_dir=$2
  local line=$3

  # Ignore comments and empty lines
  [[ "$line" =~ ^# ]] && return
  [[ -z "$line" ]] && return

  # Remove leading hyphen (if any)
  line=$(echo "$line" | sed 's/^-//')

  # Remove everything after ';' including ';'
  line=$(echo "$line" | sed 's/;.*//')

  # If there's a colon, handle source and destination paths
  if [[ "$line" == *:* ]]; then
    src_file=$(echo "$line" | cut -d ':' -f 1)
    dest_file=$(echo "$line" | cut -d ':' -f 2)

    # Check if the source file exists and copy it to the destination
    if [ -f "$src_dir/$src_file" ]; then
      copy_file_with_subdirs "$src_dir" "$dest_dir" "$src_file" "$dest_file"
      echo "Copied $src_file to $dest_file."
    else
      echo "$src_file:$dest_file not found in $src_dir." | tee -a "$MISSING_LOG"
    fi
  else
    # Regular file processing (without colon)
    if [ -f "$src_dir/$line" ]; then
      copy_file_with_subdirs "$src_dir" "$dest_dir" "$line" "$line"
      echo "Copied $line from $src_dir to $dest_dir."
    else
      echo "$line not found in $src_dir." | tee -a "$MISSING_LOG"
    fi
  fi
}

# Copy files from banana1.txt (from SEA_DIR to FLEUR_DEST_DIR)
while IFS= read -r file; do
  process_line "$SEA_DIR" "$FLEUR_DEST_DIR" "$file"
done < "$P_FILES_TXT"

# Copy files from banana2.txt (from FLEUR_SRC_DIR to FLEUR_DEST_DIR)
while IFS= read -r file; do
  process_line "$FLEUR_SRC_DIR" "$FLEUR_DEST_DIR" "$file"
done < "$P_FILES_FLEUR_TXT"

cp -r priv-app vendorz/system/
