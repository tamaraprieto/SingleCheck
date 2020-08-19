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

if [ "$GENDER" = "XX" ]
then
        num=23
        pattern_match="^[1-9|X]"
else
        num=22
        pattern_match="^[1-9]"
fi

# The following code can be problematic
# Pipe and redirect symbols
if [[ ! -f ${WORKDIR}/${REF}.${size}bp.bed ]]
then
awk '{print $1"\t"$2}' ${RESDIR}/${REF}.fai | \
	grep "$pattern_match" > ${WORKDIR}/${REF}.txt
bedtools makewindows -w ${size} -g ${WORKDIR}/${REF}.txt| awk '{print $1"\t"$2"\t"$3}' >${WORKDIR}/${REF}.${size}bp.bed
fi

module load gcc/6.4.0 samtools/1.9
samtools index ${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam
samtools bedcov ${WORKDIR}/${REF}.${size}bp.bed \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam  > \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.${size}bp.bed

module purge
module load miniconda2/4.5.11
source activate /mnt/netapp2/Store_uni/home/uvi/be/tpf/conda/python3
python ${SCRIPTDIR}/OurMADImplementation.py $SAMPLE $WORKDIR $DEPTH $size
source deactivate
