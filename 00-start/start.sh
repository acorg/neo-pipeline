#!/bin/bash -e

. ../common.sh

log=$sampleLogFile

logStepStart $log

# Remove the marker file that indicates when a job is fully complete or
# that there has been an error and touch the file that shows we're running.
rm -f $doneFile $errorFile
touch $runningFile

# Remove the top-level logging directory. With a sanity check!
if [ ! $logDir = ../logs ]
then
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "  logDir variable has unexpected value '$logDir'!" >>$log
    logStepStop $log
    exit 1
fi

rm -fr $logDir

mkdir $logDir || {
    # SLURM will catch this output and put it into slurm-N.out where N is
    # out job id.
    echo "  Could not create log directory '$logDir'!" >>$log
    logStepStop $log
    exit 1
}

if [ ! -d $statsDir ]
then
    echo "  Making stats directory '$statsDir'." >> $log
    mkdir $statsDir || {
        echo "  Could not make stats dir '$statsDir'!" >> $log
        logStepStop $log
        exit 1
    }
fi

tasks=$(tasksForSample)

for task in $tasks
do
    fastq=$dataDir/$task.trim.fastq.gz

    if [ ! -f $fastq ]
    then
        echo "  Task $task FASTQ file '$fastq' does not exist!" >> $log
        logStepStop $log
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

logStepStop $log
