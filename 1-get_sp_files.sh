#!/bin/bash

# SSP-SP tables are not actually XLS files. They are weird TSVs that have a ton
# of NUL characters in the middle. This script removes these NUL characters,
# and then converts these files to UTF-8 (since there are often issues when
# trying to read them on R with the original Latin1 encoding for whatever
# reason).

for table in ./raw_crime_data/sp/*.xls; do
  gsed -i 's/\x0//g' "$table"
  iconv -f latin1 -t utf-8 "$table" > "${table%.*}".tsv
  rm "$table"
done
