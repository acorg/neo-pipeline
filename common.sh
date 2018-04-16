# IMPORTANT: All (relative) paths in this file are relative to the scripts
# in 00-start, etc. This file is sourced by those scripts.

logDir=../logs
log=$logDir/common.sh.stderr
root=/rds/project/djs200/rds-djs200-acorg/bt/root

if [ ! -d $root ]
then
    echo "  Root directory '$root' does not exist." >> $log
    exit 1
fi

activate=$root/share/virtualenvs/365/bin/activate

if [ ! -f $activate ]
then
    echo "  Virtualenv activation script '$activate' does not exist." >> $log
    exit 1
fi

. $activate

dataDir=../../../..
doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
sampleLogFile=$logDir/sample.log
statsDir=$dataDir/stats
sequencingToSample=$dataDir/sequencing-to-sample

if [ ! -f $sequencingToSample ]
then
    echo "  Sequencing to sample file '$sequencingToSample' not found!" >> $log
    exit 1
fi

# A simple way to set defaults for our SP_* variables, without causing
# problems by using test when set -e is active (causing scripts to exit
# with status 1 and no explanation).
echo ${SP_SIMULATE:=0} ${SP_SKIP:=0} ${SP_FORCE:=0} >/dev/null

function sampleName()
{
    # The sample name is the basename of our parent directory.
    echo $(basename $(dirname $(/bin/pwd)))
}

function tasksForSample()
{
    local sample=$(sampleName)

    # Emit a task for all sequencing files that correspond to this sample.
    tasks=$(egrep "^N[0-9]+ $sample\$" $sequencingToSample | awk '{print $1}')

    if [ -z "$tasks" ]
    then
        echo "  No matches for sample '$sample' found in $sequencingToSample!" >> $log
        exit 1
    fi

    echo $tasks
}

function logStepStart()
{
    # Pass a log file name.
    case $# in
        1) echo "$(basename $(pwd)) started at $(date) on $(hostname)." >> $1;;
        *) echo "logStepStart must be called with 2 arguments." >&2;;
    esac
}

function logStepStop()
{
    # Pass a log file name.
    case $# in
        1) echo "$(basename $(pwd)) stopped at `date`" >> $1; echo >> $1;;
        *) echo "logStepStop must be called with 2 arguments." >&2;;
    esac
}

function checkFastq()
{
    local fastq=$1
    local log=$2

    echo "  Checking FASTQ file '$fastq'." >> $log

    if [ ! -f $fastq ]
    then
        echo "  FASTQ file '$fastq' does not exist according to test -f." >> $log

        if [ -L $fastq ]
        then
            dest=$(readlink $fastq)
            echo "  $fastq is a symlink to $dest." >> $log
            echo "  Attempting to use zcat to read the destination file '$dest'." >> $log
            # zcat $dest | head >/dev/null
            zcat $dest | head >>$log
            case $? in
                0) echo "    zcat read succeeded." >> $log;;
                *) echo "    zcat read failed." >> $log;;
            esac
            echo "  Attempting to use zcat to read the link '$fastq'." >> $log
            zcat $fastq | head >>$log
            # zcat $fastq | head >/dev/null
            case $? in
                0) echo "    zcat read succeeded." >> $log;;
                *) echo "    zcat read failed." >> $log;;
            esac
        fi

        echo "  Sleeping to see if '$fastq' becomes available." >> $log
        sleep 3

        if [ ! -f $fastq ]
        then
            echo "  FASTQ file '$fastq' still does not exist according to test -f." >> $log
            logStepStop $log
            exit 1
        fi
    fi
}
