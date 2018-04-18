#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/$task.log
fastq=$dataDir/$task.trim.fastq.gz
countOut=$statsDir/$task.read-count
MD5Out=$statsDir/$task.md5
lengthDistributionOut=$statsDir/$task.read-lengths

logStepStart $log
logTaskToSlurmOutput $task $log
checkFastq $fastq $log

function stats()
{
    # Remove all output files before doing anything, in case we fail for
    # some reason (this script has sometimes run out of memory - not sure
    # why).
    rm -f $lengthDistributionOut $countOut $MD5Out

    # Write a file of frequency of read lengths. Do it in several steps, to
    # reduce peak memory consumption.
    tmp1=$task.tmp1
    tmp2=$task.tmp2

    zcat $fastq | fasta-lengths.py --fastq | awk '{print $NF}' > $tmp1

    sort < $tmp1 > $tmp2
    rm $tmp1; mv $tmp2 $tmp1

    uniq -c < $tmp1 > $tmp2
    rm $tmp1; mv $tmp2 $tmp1

    sort -nr < $tmp1 > $lengthDistributionOut
    rm $tmp1

    # The total number of reads is the sum of the above length frequencies.
    echo -n "$fastq " > $countOut
    awk '{sum += $1} END {print sum}' < $lengthDistributionOut >> $countOut

    md5sum $fastq > $MD5Out
}

if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Stats is being skipped on this run." >> $log
    elif [ -f $countOut -a -f $MD5Out -a -f $lengthDistributionOut ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut exist, but --force was used. Overwriting." >> $log
            stats
        else
            echo "  Will not overwrite pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output files $countOut, $MD5Out, and $lengthDistributionOut do not all exist. Collecting stats." >> $log
        stats
    fi
fi

logStepStop $log
