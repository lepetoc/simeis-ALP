#!/bin/bash
while read todo; do
    exit 1
done < <(grep 'TODO' -r ../ --exclude-dir=scripts | grep -v 'TODO (' )