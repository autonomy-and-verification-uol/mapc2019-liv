#!/bin/sh

# arguments: 1 domain file; 2 problem_file; 3 plan file

/home/angelo/git/planner/./fast-downward.py --plan-file $3 --search-time-limit 1s --alias seq-opt-lmcut $1 $2 > /dev/null 2>&1

if [ -e $3 ]; then
    cat $3 | sed '/^;/d; s/(\([^ _]*\)[^ ]*\ \([a-z0-9]*\).*/\1(\2)/g; s/\([pn][0-5]\)\([pn][0-5]\)/\1,\2/g; s/p//g; s/n\([0-5]\)/-\1/g'
    rm $3
else
    echo "NO PLAN" 
fi

###rm $3 > /dev/null 2>&1
