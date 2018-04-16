#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/$task.log
fastq=$dataDir/$task.trim.fastq.gz
countOut=$statsDir/$task.read-count
MD5Out=$statsDir/$task.md5
lengthDistributionOut=$statsDir/$task.read-lengths

logStepStart $log

echo "  Running on $(hostname)" >> $log
echo "  FASTQ is $fastq" >> $log

if [ -L $fastq ]
then
    dest=$(readlink $fastq)
    echo "  $fastq is a symlink to $dest." >> $log
    echo "  Attempting to use zcat to read the destination file '$dest'." >> $log
    zcat $dest | head >/dev/null
    case $? in
        0) echo "    zcat read succeeded." >> $log;;
        *) echo "    zcat read failed." >> $log;;
    esac
    echo "  Attempting to use zcat to read the link '$fastq'." >> $log
    zcat $fastq | head >/dev/null
    case $? in
        0) echo "    zcat read succeeded." >> $log;;
        *) echo "    zcat read failed." >> $log;;
    esac
fi

echo "  Sleeping to see if $fastq becomes available." >> $log
sleep 3

if [ ! -f $fastq ]
then
    echo "  FASTQ file '$fastq' does not exist." >> $log
    logStepStop $log
    exit 1
fi

function stats()
{
    # Write a file of frequency of read lengths.
    zcat $fastq | filter-fasta.py --fastq |
        awk 'NR % 4 == 2 {print length}' | sort | uniq -c | sort -nr > $lengthDistributionOut

    # The total number of reads is the sum of the above length frequencies.
    echo -n "$fastq " > $countOut
    awk '{sum += $1} END {print sum}' < $lengthDistributionOut >> $countOut

    md5sum $fastq > $MD5Out
}

echo "  FASTQ is $fastq" >> $log

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
