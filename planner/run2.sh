#!/bin/sh

# arguments: 1 domain file; 2 agent name

/LOCAL/papacchf/fastdownward/./fast-downward.py --sas-file ${2}.sas --plan-file ${2}_output --search-time-limit 1s --alias seq-opt-lmcut $1 ${2}_problem.pddl > /dev/null 2>&1

if [ -e ${2}_output ]; then
    cat ${2}_output | sed '/^;/d; s/(\([^ _]*\)[^ ]*\ \([a-z0-9]*\).*/\1(\2)/g; s/\([pn][0-5]\)\([pn][0-5]\)/\1,\2/g; s/p//g; s/n\([0-5]\)/-\1/g' 
    rm ${2}_output ${2}.sas
else
    echo "NO PLAN"
fi

###rm $3 > /dev/null 2>&1
