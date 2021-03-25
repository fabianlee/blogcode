#!/bin/bash
#
# chain 2 sed substitutions for output
#

sed "s/hello/goodbye/g; s/quick/slow/g" <<EOF
hello, world!
hello, universe!
the quick brown fox
EOF

