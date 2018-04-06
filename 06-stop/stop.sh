#!/bin/bash -e

. ../common.sh

log=$sampleLogFile

logStepStart $log

echo "  Creating $doneFile." >> $log
touch $doneFile

echo "  Removing $runningFile." >> $log
rm -f $runningFile

logStepStop $log
