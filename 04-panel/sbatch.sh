#!/bin/bash -e

. ../common.sh

log=$logDir/sbatch.log

echo "04-panel sbatch.sh running at `date`" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

jobid=`sbatch -n 1 $SP_DEPENDENCY_ARG submit.sh "$@" | cut -f4 -d' '`
echo "TASK: panel $jobid"

echo "  Job id is $jobid" >> $log
echo >> $log
