#!/bin/bash -e

. ../common.sh

# Remove the marker file that indicates when a job is fully complete or
# that there has been an error and touch the file that shows we're running.
rm -f $doneFile $errorFile
touch $runningFile

# Remove the top-level logging directory. With a sanity check!
if [ ! $logDir = ../logs ]
then
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: logDir variable has unexpected value '$logDir'!" >&2
    exit 1
fi

rm -fr $logDir

mkdir $logDir || {
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "$0: Could not create log directory '$logDir'!" >&2
    exit 1
}

log=$sampleLogFile

echo "SLURM pipeline started at `date`" >> $log

echo >> $log
echo "00-start started at `date`" >> $log

if [ ! -f $sequencingToSample ]
then
    echo "  Sequencing to sample file '$sequencingToSample' not found!" >> $log
    exit 1
fi

if [ ! -d $statsDir ]
then
    echo "  Making stats directory '$statsDir'." >> $log
    mkdir $statsDir || {
        echo "  Could not make stats dir '$statsDir'!" >> $log
        exit 1
    }
fi


sample=$(sampleName)

# Emit a task for all sequencing files that correspond to this sample.
tasks=$(egrep "^N[0-9]+ $sample\$" $sequencingToSample | awk '{print $1}')

if [ -z "$tasks" ]
then
    echo "  No matches for sample '$sample' found in $sequencingToSample!" >> $log
    exit 1
fi

for task in $tasks
do
    fastq=$dataDir/$task.trim.fastq.gz

    if [ ! -f $fastq ]
    then
        echo "  Task $task FASTQ file '$fastq' does not exist!" >> $log
        exit 1
    fi

    echo "  task $task, FASTQ $fastq" >> $log
done

for task in $tasks
do
    # Emit task names (without job ids as this step does not start any
    # SLURM jobs).
    echo "TASK: $task"
done

echo "00-start stopped at `date`" >> $log
echo >> $log
