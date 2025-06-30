#!/bin/bash
# grep 'TODO' -r --exclude=../scripts/todo_checker.sh ../ > todos.txt
# readarray -t todos < <( grep 'TODO' -r ../ )

readarray -t todos < <(grep 'TODO' -r ../)

echo ${todos[@]}
# for todo in ${todos[@]}
# do
#    echo ${todo}
# done