#!/bin/bash
#SBATCH --account=def-bmaxwell
#SBATCH --mail-user=igaud058@uottawa.ca
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --job-name=2D34k7_6
#SBATCH --nodes=1
#SBATCH --ntasks=128
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2048M
#SBATCH --time=01-00:00
BIN=mg_torch

mpirun $BIN <<- EOF
	\$read run
	q
	EOF



