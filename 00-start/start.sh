#!/bin/bash -e

. ../common.sh

# We cannot initially write to a log file because the log directory may not
# exist yet. So write initial errors to stderr.

# Remove the top-level logging directory (with a sanity check on its name).
if [ ! "$logDir" = ../logs ]
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

# From here on we can write errors to a log file.

log=$sampleLogFile
logStepStart $log

# Remove the marker files that indicate when a job is fully complete or
# that there has been an error and touch the file that shows we're running.
rm -f $doneFile $errorFile
touch $runningFile

if [ ! -d $statsDir ]
then
    echo "  Making stats directory '$statsDir'." >> $log
    mkdir $statsDir || {
        echo "  Could not make stats dir '$statsDir'!" >> $log
        logStepStop $log
        exit 1
    }
fi

echo "  Removing all old slurm-*.out files." >> $log
rm -f ../0*/slurm-*.out

tasks=$(tasksForSample)

for task in $tasks
do
    fastq=$dataDir/$task.trim.fastq.gz
    checkFastq $fastq $log
    echo "  task $task, FASTQ $fastq" >> $log
done

for task in $tasks
do
    # Emit task names (without job ids as this step does not start any
    # SLURM jobs).
    echo "TASK: $task"
done

logStepStop $log
