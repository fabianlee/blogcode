#!/bin/bash
# 
# supports blog: 
#
# Shows how awk can have use embedded bash variable
#

thedir="/tmp"
ls $thedir | awk -v thedir=$thedir '{ printf "directory %s has file %s\n",thedir,$1 }'
