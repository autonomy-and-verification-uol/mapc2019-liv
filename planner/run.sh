#!/bin/sh

# arguments: 1 domain file; 2 problem_file; 3 plan file

/LOCAL/papacchf/fastdownward/./fast-downward.py --plan-file $3 --overall-time-limit 1s --alias seq-opt-lmcut $1 $2 > /dev/null 2>&1

retVal=$?

if [ $retVal -eq 0 ]; then
    cat $3 | sed '/^;/d; s/(\([^ _]*\)[^ ]*\ \([a-z0-9]*\).*/\1(\2)/g; s/\([pn][0-5]\)\([pn][0-5]\)/\1,\2/g; s/p//g; s/n\([0-5]\)/-\1/g' 
else
    echo "NO PLAN" 
fi
