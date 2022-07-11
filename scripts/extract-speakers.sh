#!/usr/bin/env bash

# This script queries speaker JSON files from a local exist database
# saves them to meta/speakers/ and regenerates the respective TEI
# documents. The database is expected to contain the manually refined
# play from the manual_refinery branch.

# expects command line arguments as "dracorid:epid", see refined.txt

if [ ! -d meta/speakers -o ! -d ../epdracor-sources/xml ]; then
  echo "This script must be run from the repository's root directory."
  echo "The epdracor-sources repo ('dracor' branch) needs to be checked out"
  echo "next to it."
  echo
  exit 1
fi

for arg in $@; do
  echo $arg
  id=$(echo $arg | cut -d: -f1)
  epid=$(echo $arg | cut -d: -f2)
  echo "  $id"
  echo "  $epid"
  http ":8080/exist/rest/db/apps/dracor/speakers.xq?id=$id" \
    | jsonlint > meta/speakers/$epid.json
  ./ep2dracor ../epdracor-sources/xml/$epid.xml
done
