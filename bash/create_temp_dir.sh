#!/bin/bash
# 
# Creates temp directory where temp files can be created
# blog: 
#

# create temporary directory
tmp_dir=$(mktemp -d)
echo "tmp_dir = $tmp_dir"

# create temp file in the temp dir
tmp_file=$(mktemp -p $tmp_dir)
echo "tmp_file = $tmp_file"

# create temp file with suffix in the temp dir
tmp_file=$(mktemp -p $tmp_dir --suffix=.tgz)
echo "tmp_file (tgz) = $tmp_file"

# cleanup
echo "deleting tmp_dir"
rm -fr $tmp_dir
