#!/bin/bash

set -e

DOWNLOAD_DIR=/mnt/c/Users/pelle/Downloads
DOWNLOAD_GLOB=BLT-documentation*.7z
OUTPUT_DIR=$(dirname $0)
CHANGELOG=changelog.txt

archive=$(ls -1t ${DOWNLOAD_DIR}/${DOWNLOAD_GLOB} | head -n1)

## check for correct file
echo "Found: $(ls -lt $archive | tail -n1)"
read -n 1 -p "Continue? (y/n) " response
echo
[[ "y" == "${response}" ]] || exit 1

## extract archive
cd $OUTPUT_DIR
7z x -bb0 -y ${archive} >/dev/null

## check for changes
if [[ "" == "$(git status --porcelain)" ]]; then
    echo "no changes"
    exit 0
fi

## generate changelog
# find all diffs that do not start with an '<img' tag
git diff --no-color -G. | \
    grep -EB2 '^(\+|-)' > ${CHANGELOG}

## add changelog to index.html
sed -e "s/^<div class=\"toc-container\">/<a href=\"changelog.txt\">Changelog for $(date +%F)<\/a>.<div class=\"toc-container\">/" index.html > index.html.new
mv index.html.new index.html

## commit changes
git add .
git commit -m "update from shmoop"

## push changes
git push origin master

echo Done
