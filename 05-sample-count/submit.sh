#!/bin/bash -e

#SBATCH -J sample-count
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=10:00:00

srun -n 1 sample-count.sh
