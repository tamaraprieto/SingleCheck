#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 30G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE
DEPTH=$2

module load gcc/6.4.0 samtools/1.9
samtools mpileup \
	--no-BAQ \
	--fasta-ref ${RESDIR}/${REF}.fa \
	-q 20 \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam > \
	${WORKDIR}/${SAMPLE}.${DEPTH}.mpileup

module purge
module load miniconda2/4.5.11
source activate /mnt/netapp2/Store_uni/home/uvi/be/tpf/conda/python3
python /mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts/CorrelationMagnitude.py $SAMPLE $WORKDIR $DEPTH
source deactivate
