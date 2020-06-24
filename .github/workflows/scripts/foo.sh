#!/bin/sh

SOURCE="ArtifexSoftware/mupdf"
TAGS="$(curl --location --silent -H "Accept: application/json" "https://api.github.com/repos/$SOURCE/tags")"
LATEST_VERSION="$(echo "$TAGS" | grep '"name"' | head -1 | sed -e 's/.*\"name\": \"\([^\"]\+\)\".*/\1/')"
echo $LATEST_VERSION
