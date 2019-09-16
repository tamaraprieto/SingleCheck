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


module load gcc/6.4.0 samtools/1.9
module load gcccore/6.4.0 preseq/2.0.3
for RG in `samtools view -H /mnt/netapp1/Store_uvibetpf/Single-Cell/RESULTS/${SAMPLE}.dedup.bam | grep "^@RG" | awk '{print $2}' | sed 's/ID://'`
do
bam2mr \
	-v \
	-o ${WORKDIR}/${SAMPLE}.${RG}.mr \
	${WORKDIR}/${SAMPLE}.dedup.${RG}.bam

preseq gc_extrap \
	-v \
	-o ${WORKDIR}/${SAMPLE}.${RG}.inferredcov.txt \
	${WORKDIR}/${SAMPLE}.${RG}.mr

depth=5
genome_len=$(awk '{sum+=$2}END{print sum}' ${RESDIR}/${REF}.fai)
awk -v len=$genome_len '{print $1/len"\t"$2/len"\t"$3/len"\t"$4/len}' ${WORKDIR}/${SAMPLE}.${RG}.inferredcov.txt | awk -v depth=$depth 'BEGIN{a=depth-0.00001}{if ($1>=a){print $2*100}}' | head -n 1 | awk -v sample=${SAMPLE} -v RG=${RG} '{print sample"\t"RG"\t"$0}'> ${WORKDIR}/${SAMPLE}.${RG}.inferredcov.${depth}X.txt
done
