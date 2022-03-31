#!/usr/bin/env bash

cur_date=$(date "+%Y-%m-%d")
curl -L 'https://git.sr.ht/~heywoodlh/docs/blob/master/reading-list.md' -o _posts/${cur_date}-reading-list.md

jekyll build

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
        mv -v $original _site/$filename
    fi
done
