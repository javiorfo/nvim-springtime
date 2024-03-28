#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST_FOLDER="$(dirname "$CURRENT_DIR")/lua/springtime/libraries.lua"
SPRING_URL="https://start.spring.io"

echo "return {" > $DEST_FOLDER 
curl -H 'Accept: application/json' $SPRING_URL | jq -r '.dependencies.values[].values[] | "\t{ label = \"" + .name + "\", insertText = \"" + .id + ",\" },"' >> $DEST_FOLDER
echo "}" >> $DEST_FOLDER
