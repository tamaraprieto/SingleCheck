#!/bin/bash
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

if [ "$GENDER" = "XX" ]
then
        num=23
        pattern_match="^[1-9|X]"
else
        num=22
        pattern_match="^[1-9]"
fi

#module purge
#module load gcccore/6.4.0 bedtools/2.27.1
## The following code can be problematic
## Pipe and redirect symbols
#if [[ ! -f ${WORKDIR}/${REF}.${size}bp.bed ]]
#then
#awk '{print $1"\t"$2}' ${RESDIR}/${REF}.fai | \
#	grep "$pattern_match" > ${WORKDIR}/${REF}.txt
#bedtools makewindows -w ${size} -g ${WORKDIR}/${REF}.txt| awk '{print $1"\t"$2"\t"$3}' >${WORKDIR}/${REF}.${size}bp.bed
#fi
#
## Another alternative: bedtools multicov [OPTIONS] -bams BAM1 BAM2 BAM3 ... BAMn -bed  <BED/GFF/VCF>
#module load gcc/6.4.0 samtools/1.9
#samtools index ${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam
#samtools bedcov \
#	-Q 20 \
#	${WORKDIR}/${REF}.${size}bp.bed \
#	${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam  > \
#	${WORKDIR}/${SAMPLE}.${DEPTH}X.${size}bp.bed

if [[ "$size" = 1 ]]
then
        module purge
	module load gcc/6.4.0 samtools/1.9
        CHR="All"
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
	
	num=2
	tail -n +${num} ${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup | \
	        paste ${WORKDIR}/${SAMPLE}.chr${CHR}.${DEPTH}.mpileup - | \
	        awk '{if (NF==12 && $3!="N" && $9!="N" && $1==$7) {print $4"\t"$10} else if (NF==12 && $3!="N" && $9!="N" && $1!=$7){print $4}}' \
	        > ${WORKDIR}/ForMAD.${SAMPLE}.${DEPTH}.${size}.txt
	
	
else
	module load miniconda3/4.8.2
	source activate /mnt/netapp1/posadalab/APPS/CommonCondaEnvironments/mosdepth
	# --fast-mode dont look at internal cigar operations or correct mate overlaps (recommended for most use-cases). Avoids the extra calculations of mate pair overlap and cigar operations
	# 772 flag: exclude read unmapped, not primary alignment, read fails platform/vendor quality checks
	
	########################################################################
	# Instead of doing windows, do intervals from the mappability regions? # 
	########################################################################
	# For size=1 use mpileup as in Autocorrelation!! #
	
	MOSDEPTH_PRECISION=10 mosdepth \
		-t 3 \
		--no-per-base \
		--fast-mode \
		--by $size \
		--flag 772 \
		--mapq 20 \
		${WORKDIR}/${SAMPLE}.${DEPTH}X \
		${WORKDIR}/${SAMPLE}.${DEPTH}X.filtered.bam
	conda deactivate
	# Output ${WORKDIR}/${SAMPLE}.${DEPTH}X.regions.bed.gz contains mean base depth per window
	
	# Paste values from consecutive windows together 
	# I do not want to consider the counts from the last window because is shorter than the other
	# I should not use last comparison neither because it uses last window for one elemente. I have to only use the first column for calculating the average depth
	zcat ${WORKDIR}/${SAMPLE}.${DEPTH}X.regions.bed.gz | \
		tail -n +2 | \
	        paste  <(zcat ${WORKDIR}/${SAMPLE}.${DEPTH}X.regions.bed.gz) - | \
	        grep "$pattern_match" | \
	        awk '{if (NF==8 && $1==$5) {print $4"\t"$8} else if (NF==8 && $1!=$5){print $4}}' \
		> ${WORKDIR}/ForMAD.${SAMPLE}.${DEPTH}.${size}.txt
fi


module purge
module load miniconda2/4.5.11
source activate /mnt/netapp2/Store_uni/home/uvi/be/tpf/conda/python3
#python ${SCRIPTDIR}/OurMADImplementation.py $SAMPLE $WORKDIR $DEPTH $size
python ${SCRIPTDIR}/MAD.py $SAMPLE $WORKDIR $DEPTH $size
source deactivate

rm ${WORKDIR}/ForMAD.${SAMPLE}.${DEPTH}.${size}.txt
