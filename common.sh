# IMPORTANT: All paths in this file are relative to the scripts in
# 00-start, etc. This file is sourced by those scripts.

. /rds/project/djs200/rds-djs200-acorg/bt/root/share/virtualenvs/365/bin/activate

dataDir=../../../..
logDir=../logs
doneFile=../slurm-pipeline.done
runningFile=../slurm-pipeline.running
errorFile=../slurm-pipeline.error
sampleLogFile=$logDir/sample.log
statsDir=$dataDir/stats
sequencingToSample=$dataDir/sequencing-to-sample

# A simple way to set defaults for our SP_* variables, without causing
# problems by using test when set -e is active (causing scripts to exit
# with status 1 and no explanation).
echo ${SP_SIMULATE:=0} ${SP_SKIP:=0} ${SP_FORCE:=0} >/dev/null

function sampleName()
{
    # The sample name is the basename of our parent directory.
    echo $(basename $(dirname $(/bin/pwd)))
}
