#!/bin/sh

# SET UP VARIABLES
DEPTH="20X"
DATASET=HUANG


export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts:$PATH
CONFIG=$POSADALAB2/uvibetpf/SCCoverageUniformity/Config.CoverageBias.$DATASET
source ReadConfig.sh $CONFIG
num_samples=$(wc -l $ORIDIR/$SAMPLELIST | awk '{print $1}')

rm JobIDs.${DATASET}.allsizes.out
size=10000000
#for size in 1 10 25 50 75 90 100 150 250 500 750 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 50000 100000 500000 1000000 5000000 10000000
#do
NAME="${WORKDIR}/${SAMPLE}.sorted.${DEPTH}"
slurm_stdout=$(sbatch -p cola-corta,thinnodes --array=1-${num_samples} SingleCheckArray -w $size -a $size $CONFIG $DEPTH) 
echo $slurm_stdout
JOB_id=$(echo $slurm_stdout | awk '{print $4}')
echo $NAME $size $JOB_id >> JobIDs.${DATASET}.allsizes.out
#done
