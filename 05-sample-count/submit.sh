#!/bin/bash -e

#SBATCH -J sample-count
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=00:01:00

sample-count.sh
