#!/bin/bash -e

. ../common.sh

# The log file is the top-level sample log file, seeing as this step is a
# 'collect' step that is only run once.
log=$sampleLogFile

logStepStart $log
logTaskToSlurmOutput sample-count $log

tasks=$(tasksForSample)
sample=$(sampleName)

out=$statsDir/$sample.read-count

function skip()
{
    # We're being skipped. Make an output file with a zero count, if the
    # output file doesn't already exist.

    [ -f $out ] || echo "$sample 0" > $out
}

function sample_count()
{
    echo "  sample count started at `date`" >> $log
    rmFileAndLink $out

    for task in $tasks
    do
        cat $statsDir/$task.read-count
    done | awk '{sum += $2} END {printf "'$sample' %d\n", sum}' > $out
    echo "  sample count stopped at `date`" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Sample count is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            sample_count
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Summing reads for sample." >> $log
        sample_count
    fi
fi

logStepStop $log
