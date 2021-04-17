#!/bin/bash
#
# chain 2 sed substitutions for output
# https://fabianlee.org/2021/03/25/bash-performing-multiple-substitutions-with-a-single-sed-invocation/
#
# substitution with exclusion pattern
# https://fabianlee.org/2021/04/17/bash-sed-substitution-with-an-exclusion-pattern/
#

echo "***chained substitutions separated by semicolon..."

sed "s/hello/goodbye/g; s/quick/slow/g" <<EOF
hello, world!
hello, universe!
the quick brown fox
EOF

echo ""
echo "***substitution preceded by exclusion..."

sed "/\(world\|galaxy\)/! s/hello/goodbye/g; s/quick/slow/g" <<EOF
hello, world!
hello, galaxy!
hello, universe!
the quick brown fox
EOF

