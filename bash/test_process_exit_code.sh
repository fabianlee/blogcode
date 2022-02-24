#!/bin/bash
# force a process failure exit code using exit in subshell

$(exit 99)

echo "last process exit code was $?"


