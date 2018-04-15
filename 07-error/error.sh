#!/bin/bash -e

. ../common.sh

log=$sampleLogFile

logStepStart $log

echo "  ERROR!! SLURM pipeline finished at `date`" >> $log

echo "  Creating $errorFile." >> $log
touch $errorFile

logStepStop $log
