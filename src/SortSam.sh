#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH -t 12:00:00
#SBATCH --mem 40G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${IDLIST})
echo $SAMPLE

module load picard/2.18.14
java -jar $EBROOTPICARD/picard.jar \
	SortSam \
	I=${ORIDIR}/${SAMPLE}.bam \
	TMP_DIR=${WORKDIR} \
	O=${WORKDIR}/${SAMPLE}.sorted.bam \
	CREATE_INDEX=true \
	SORT_ORDER=coordinate \
	VALIDATION_STRINGENCY=LENIENT
