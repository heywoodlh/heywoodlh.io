#!/usr/bin/env bash

#jekyll build

# Remove the .html extension from all blog posts for sexy URLs
for filename in _site/*.html; do
    if [ $filename != "_site/index.html" ];
    then
        original="$filename"

        # Get the filename without the path/extension
        filename=$(basename "$filename")
        extension="${filename##*.}"
        filename="${filename%.*}"

        # Move it
	echo "mv: $original => _site/$filename"
        #mv $original _site/$filename
    fi
done
