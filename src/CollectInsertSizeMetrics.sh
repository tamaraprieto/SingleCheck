#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 00:30:00
#SBATCH --mem 30G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

module purge
module load picard/2.18.14
module load gcc/6.4.0 R/3.5.1

java -jar $EBROOTPICARD/picard.jar \
	CollectInsertSizeMetrics \
	I=${WORKDIR}/${SAMPLE}.sorted.bam \
	O=${WORKDIR}/${SAMPLE}.insert_size_metrics.txt \
	H=insert_size_histogram.pdf
