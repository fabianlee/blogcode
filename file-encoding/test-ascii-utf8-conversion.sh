#!/bin/bash
#
# creates a text file with ascii7 encoding and then utf-8 with embedded unicode character
#

# remove any files from last run
rm -f test-ascii.txt test-utf8.txt test-bom-utf8.txt

# create two test files, one with utf8 encoding and Unicode
printf 'Hello, World!' > test-ascii.txt
printf 'Hello,\xE2\x98\xA0World!' > test-utf8.txt
printf '\xEF\xBB\xBFHello,\xE2\x98\xA0World!' > test-bom-utf8.txt

# show file encoding types
echo "==file encoding==========================="
file -bi test-ascii.txt
file -bi test-utf8.txt
file -bi test-bom-utf8.txt

# show hex/ascii dump
echo "==hex dumps==========================="
cat test-ascii.txt | hexdump -C
cat test-utf8.txt | hexdump -C
cat test-bom-utf8.txt | hexdump -C

# do conversion from utf-8 to ascii, throw away unicode sequences
echo "==convert to ASCII==========================="
iconv -f UTF-8 -t ASCII//IGNORE test-utf8.txt 2>/dev/null > test-utf8-to-ascii.txt
file -bi test-utf8-to-ascii.txt
cat test-utf8-to-ascii.txt | hexdump -C
