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
SIZE=$3
CHR=All

module load gcc/6.4.0 samtools/1.9
if [[ ! -f ${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup ]]
then
samtools mpileup \
	--no-BAQ \
	--fasta-ref ${RESDIR}/${REF}.fa \
	-aa \
	-q 20 \
	${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam > \
	${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup
#         --region ${CHR} \
fi

num=$(awk -v size=$SIZE 'BEGIN{print size+1}')
tail -n +${num} ${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup | \
	paste ${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup - | \
	awk '{if (NF==12 && $3!="N" && $9!="N") {print $3"\t"$9"\t"$4"\t"$10} else if (NF==6 && $3!="N"){print $3"\t"$4}}' \
	> ${WORKDIR}/CorrMag.${SAMPLE}.chr${CHR}.${DEPTH}.${SIZE}.txt

module purge
module load miniconda2/4.5.11
source activate /mnt/netapp2/Store_uni/home/uvi/be/tpf/conda/python3
python ${SCRIPTDIR}/CorrelationMagnitude.py $SAMPLE $WORKDIR $DEPTH $SIZE $CHR
source deactivate

rm ${WORKDIR}/CorrMag.${SAMPLE}.chr${CHR}.${DEPTH}.${SIZE}.txt
