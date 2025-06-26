#!/bin/bash

# Script to create .env file from host file content
# Usage: ./create-env.sh path/to/your/file.txt

if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-file>"
    exit 1
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
    echo "File $FILE_PATH does not exist"
    exit 1
fi

# Read file content and create .env file
CONTENT=$(cat "$FILE_PATH")
echo "GEMINI_API_KEY=$CONTENT" > .env

echo ".env file created with content from $FILE_PATH"
