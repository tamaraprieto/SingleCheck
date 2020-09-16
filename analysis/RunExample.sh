#!/bin/sh

#rm JobIDs.Example.out
REF="/mnt/netapp1/posadalab/phylocancer/RESOURCES/hs37d5.fa"
export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts:$PATH

while read SAMPLE
do
#slurm_stdout=$(sbatch -p amd-shared --qos=amd-shared -t 02:00:00 SingleCheck -d "^[1-9]" -r ${REF} ${SAMPLE}_1.fastq.gz ${SAMPLE}_2.fastq.gz)
slurm_stdout=$(sbatch -p thinnodes,cola-corta -t 00:30:00 SingleCheck -r ${REF} ${SAMPLE}.bam)
echo $slurm_stdout
JOB_id=$(echo $slurm_stdout | awk '{print $4}')
echo $SAMPLE $JOB_id >> JobIDs.Example.out
done < ../scripts/example/Samples.txt

