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
size=$3

module purge
module load gcccore/6.4.0 bedtools/2.27.1
# The following commented code can be problematic
# Pipe and redirect symbols
if [[ ! -f ${WORKDIR}/${REF}.${size}bp.bed ]]
then
awk '{print $1"\t"$2}' ${RESDIR}/${REF}.fai | grep "^[0-9|X]" > ${WORKDIR}/${REF}.txt
bedtools makewindows -w ${size} -g ${WORKDIR}/${REF}.txt| awk '{print $1"\t"$2"\t"$3}' >${WORKDIR}/${REF}.${size}bp.bed
fi

module load gcc/6.4.0 samtools/1.9
#samtools index ${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam
# Add the coverage counts at each position of each bed interval
samtools bedcov ${WORKDIR}/${REF}.${size}bp.bed \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam  > \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.${size}bp.bed

module purge
module load miniconda2/4.5.11
source activate /mnt/netapp2/Store_uni/home/uvi/be/tpf/conda/python3
python ${SCRIPTDIR}/CoefficientOfVariation.py $SAMPLE $WORKDIR $DEPTH $size
source deactivate
