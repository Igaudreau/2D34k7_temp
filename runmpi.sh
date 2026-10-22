#!/bin/bash
CORES=$1
BIN=mg_torch


# create kill script for this simulation
#rm kill.sh
#touch kill.sh
#PID=$$
#echo "#! /bin/bash" >> kill.sh
#echo "pkill -TERM -P "$PID >> kill.sh
#echo "rm kill.sh" >> kill.sh


mpiexec -n $CORES $BIN <<- EOF
	\$read run
	q
	EOF


# destroy kill script
#rm kill.sh



