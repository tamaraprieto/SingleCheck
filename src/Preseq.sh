#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 02:00:00
#SBATCH --mem 30G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

downsampling_depth=$2
#module load gcccore/6.4.0 preseq/2.0.3
#bam2mr \
#	-v \
#	-o ${WORKDIR}/${SAMPLE}.${downsampling_depth}.mr \
#	${WORKDIR}/${SAMPLE}.downsampled.${downsampling_depth}X.bam
#
#preseq gc_extrap \
#	-v -o ${WORKDIR}/${SAMPLE}.${downsampling_depth}.inferredcov.txt \
#	${WORKDIR}/${SAMPLE}.${downsampling_depth}.mr

depth=7.78
genome_len=$(awk '{sum+=$2}END{print sum}' ${RESDIR}/${REF}.fai)
awk -v len=$genome_len '{print $1/len"\t"$2/len"\t"$3/len"\t"$4/len}' ${WORKDIR}/${SAMPLE}.${downsampling_depth}.inferredcov.txt | awk -v depth=$depth 'BEGIN{a=depth-0.00001}{if ($1>=a){print $2*100}}' | head -n 1 > ${WORKDIR}/${SAMPLE}.${downsampling_depth}.inferredcov.${depth}X.txt
