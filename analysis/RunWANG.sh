#!/bin/sh

# SET UP VARIABLES
DEPTH="0.1X"
DATASET=WANG
SUFFIX=".${DEPTH}.filtered"

export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts:$PATH
CONFIG=$POSADALAB2/uvibetpf/SCCoverageUniformity/Config.CoverageBias.$DATASET
source ReadConfig.sh $CONFIG
num_samples=$(wc -l $ORIDIR/$SAMPLELIST | awk '{print $1}')

#rm JobIDs.${DATASET}.allsizes.out
#size=10000000
# SEND ONE JOB FIRST TO CREATE THE .MPILEUP
for size in 1 10 25 50 100 150 250 500 1000 2000 3000 5000 10000 50000 100000 500000 1000000 5000000 10000000
#for size in 1 10 25 50 100 150 250 500 1000 2000 3000 5000 10000 50000
#for size in 10000 50000 100000 500000 1000000 5000000 10000000
do
# 1-${num_samples}
slurm_stdout=$(sbatch -p amd-shared --qos=amd-shared --array=1-7 SingleCheckArray -w $size -i $size $CONFIG $SUFFIX)
#slurm_stdout=$(sbatch -p cola-corta,thinnodes --array=1-${num_samples} SingleCheckArray -w $size -a $size $CONFIG $SUFFIX) 
echo $slurm_stdout
JOB_id=$(echo $slurm_stdout | awk '{print $4}')
echo $DEPTH $size $JOB_id >> JobIDs.${DATASET}.${DEPTH}.allsizes.out
done
