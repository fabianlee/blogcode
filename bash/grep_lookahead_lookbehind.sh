#!/bin/bash
#
# Tests LookAhead and LookBehind with grep to isolate output
#

testfile="greptest.txt"

# create test file
cat > $testfile << EOF
http://www.google.com?q=foo
https://images.google.com
https://wikipedia.org/wiki/Regular_expression
https://fr.wikipedia.org/wiki/Regular_expression
http://www.yahoo.com
EOF


echo "#############################"
echo "plain grep to pull out secure and insecure URL"
grep --color -E 'https?://([^ /?\"])*' $testfile

echo ""
echo "#############################"
echo "same regex, but with -o output flag"
grep --color -Eo 'https?://([^ /?\"])*' $testfile

echo ""
echo "#############################"
echo "PCRE Perl regex with \K which resets match to simulate LookBehind"
grep -Po 'https?://\K([^ /?\"])*' $testfile

echo ""
echo "#############################"
echo "PCR Perl regex with static length LookBehind"
grep -Po "(?<=https://)([^ /?\"])*" $testfile

echo ""
echo "#############################"
echo "PCR Perl regex with brute forced variable length LookBehind, use \K instead"
grep -Po "(?:(?<=http://)|(?<=https://))([^ /?\"])*" $testfile

echo ""
echo "#############################"
echo "PCR Perl regex with LookAhead for .org domains"
grep -Po "https?://\K([^ /?\"])*(?=.com)" $testfile


# cleanup
rm $testfile

