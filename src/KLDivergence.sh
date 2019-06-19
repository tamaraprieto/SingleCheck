#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 00:10:00
#SBATCH --mem 10G

source ReadConfig.sh $1
downsampling_depth=$2

rm ${WORKDIR}/AllSamples.${downsampling_depth}.counts.txt
while read sample
do
    awk -v sample=$sample '{print sample"\t"$1"\t"$2"\t"$3}' ${WORKDIR}/${sample}.${downsampling_depth}.counts.txt >> ${WORKDIR}/AllSamples.${downsampling_depth}.counts.txt
done < ${ORIDIR}/${SAMPLELIST}

module load gcc/6.4.0 R/3.5.3
Rscript ${SCRIPTDIR}/KLDivergence.R $downsampling_depth ${WORKDIR}


