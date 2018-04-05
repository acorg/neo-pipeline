#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/sbatch.log

echo "03-diamond sbatch.sh running at `date`" >> $log
echo "  Task is $task" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_SIMULATE" = "1" -o "$SP_SKIP" = "1" ]
then
    exclusive=
    echo "  Simulating or skipping. Not requesting exclusive node." >> $log
else
    # Request an exclusive machine because diamond.sh will tell DIAMOND to
    # use 24 threads.
    exclusive=--exclusive
    echo "  Not simulating or skipping. Requesting exclusive node." >> $log
fi

jobid=`sbatch -n 1 $exclusive $SP_DEPENDENCY_ARG submit.sh $task | cut -f4 -d' '`
echo "TASK: $task $jobid"

echo "  Job id is $jobid" >> $log
echo >> $log
