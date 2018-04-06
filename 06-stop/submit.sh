#!/bin/bash -e

#SBATCH -J stop
#SBATCH -A DSMITH-SL3-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=00:01:00

srun -n 1 stop.sh
