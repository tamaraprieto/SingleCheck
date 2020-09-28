#!/bin/sh

# SET UP VARIABLES
DEPTH="0.1X"
DATASET=HUANG
SUFFIX=".sorted.${DEPTH}"

export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts/analysis/:$PATH
CONFIG=$POSADALAB2/uvibetpf/SCCoverageUniformity/Config.CoverageBias.$DATASET
source ReadConfig.sh $CONFIG
num_samples=$(wc -l $ORIDIR/$SAMPLELIST | awk '{print $1}')

#rm JobIDs.${DATASET}.allsizes.out

for size in 1 10 25 50 100 150 250 500 1000 2000 3000 5000 10000 50000 100000 500000 1000000 5000000 10000000
#for size in 1 10 25 50 100 150 250 500 1000
#for size in 10000 50000 100000 500000 1000000 5000000 10000000
do
# -p cola-corta,thinnodes
#-p shared --qos shared_short
# --array=1-${num_samples}
#slurm_stdout=$(sbatch -p thinnodes,cola-corta --array=1-8 SingleCheckArray -w $size -i $size $CONFIG $SUFFIX)
slurm_stdout=$(sbatch -p amd-shared --qos=amd-shared --array=1-8 SingleCheckArray -w $size -i $size $CONFIG $SUFFIX) 
#slurm_stdout=$(sbatch -p amd-shared --qos=amd-shared -t 03:00:00 --array=1 SingleCheckArray -w $size -i $size $CONFIG $SUFFIX)
echo $slurm_stdout
JOB_id=$(echo $slurm_stdout | awk '{print $4}')
echo $DEPTH $size $JOB_id >> JobIDs.${DATASET}.${DEPTH}.allsizes.out
done
