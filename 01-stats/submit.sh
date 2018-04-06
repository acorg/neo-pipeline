#!/bin/bash -e

#SBATCH -J stats
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=03:00:00

task=$1

srun -n 1 stats.sh $task
