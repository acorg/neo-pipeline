#!/bin/bash -e

. ../common.sh

log=$sampleLogFile

echo "ERROR!! SLURM pipeline finished at `date`" >> $log

touch $errorFile
rm -f $runningFile $doneFile
