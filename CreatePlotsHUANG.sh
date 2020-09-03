#!/bin/sh

# SET UP VARIABLES
DEPTH="20X"
DATASET=HUANG
SUFFIX=".sorted.${DEPTH}"

export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts:$PATH
CONFIG=$POSADALAB2/uvibetpf/SCCoverageUniformity/Config.CoverageBias.$DATASET
source ReadConfig.sh $CONFIG
num_samples=$(wc -l $ORIDIR/$SAMPLELIST | awk '{print $1}')
echo "Summarizing results for ${num_samples} samples"

for measurement in MAD Autocorrelation Gini CV
do
rm "${WORKDIR}/${measurement}.${DATASET}.${DEPTH}.txt"
while read sample 
do
for size in 1 10 25 50 75 90 100 150 250 500 750 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 50000 100000 500000 1000000 5000000 10000000
do
cat "${WORKDIR}/${measurement}.${sample}${SUFFIX}.${size}.txt" >> "${WORKDIR}/${measurement}.${DATASET}.${DEPTH}.txt"
done
done < $ORIDIR/$SAMPLELIST
done
