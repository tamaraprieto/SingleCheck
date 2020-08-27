#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 3
#SBATCH -t 02:00:00
#SBATCH --mem 120G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

suffix=".filtered"
#suffix="" #scWGA paper

module load gcccore/6.4.0 bedtools/2.27.1
downsampling_depth=$2
DEPTH=$2

# -----------------------------------#
# TRY TO PERFORM FILTERING BEFORE ?? #
# samtools view -q 30 -u aln.bam | bedtools genomecov -ibam - # https://www.biostars.org/p/16121/
# Read https://www.biostars.org/p/67579/
# split option in bedtools?
# http://avrilomics.blogspot.com/2016/05/assessing-read-depth-variation-based-on.html 
#------------------------------------#

bedtools genomecov \
        -ibam ${WORKDIR}/${SAMPLE}.${downsampling_depth}X${suffix}.bam \
	> ${WORKDIR}/${SAMPLE}.${downsampling_depth}X_genomecov.bed
grep "^genome" ${WORKDIR}/${SAMPLE}.${downsampling_depth}X_genomecov.bed \
	> ${WORKDIR}/${SAMPLE}.${downsampling_depth}X_genome.bed


# WANG | HUANG
if [ "$GENDER" = "XX" ]
then
	num=23
        pattern_match="^[1-9|X]"
else
	num=22
        pattern_match="^[1-9]"
fi
length_autosomes_sexchr=$(head -n $num ${RESDIR}/${REF}.fai | \
	awk '{sum+=$2}END{print sum}')

#length_autosomes_sexchr=$(grep "^[1-9|X|Y]" ${RESDIR}/${REF}.fai | \ # scWGA method
# grep "^[1-9|X|Y]" ${WORKDIR}/${SAMPLE}.${downsampling_depth}X_genomecov.bed | \ # scWGA method

grep "$pattern_match" ${WORKDIR}/${SAMPLE}.${downsampling_depth}X_genomecov.bed | \
	awk '{print $2"\t"$3}' | \
	sort -k1,1 --version-sort | \
	awk -v len="$length_autosomes_sexchr" \
	'BEGIN{prevchrom==""}{
	if ($1==prevchrom){sum+=$2;prevchrom=$1
	}else {print prevchrom"\t"sum"\t"len;prevchrom=$1;sum=$2}}' \
> ${WORKDIR}/${SAMPLE}.${downsampling_depth}.counts.txt

###########################
# ALTERNATIVE TO BEDTOOLS #
###########################

	size=1
        if [[ "$size" = 1 ]]
	then
		precision=0
	else
		precision=10
	fi	
	
        module load miniconda3/4.8.2
        source activate /mnt/netapp1/posadalab/APPS/CommonCondaEnvironments/mosdepth
        # --fast-mode dont look at internal cigar operations or correct mate overlaps (recommended for most use-cases). Avoids the extra calculations of mate pair overlap and cigar operations
        # 772 flag: exclude read unmapped, not primary alignment, read fails platform/vendor quality checks

        ########################################################################
        # Instead of doing windows, do intervals from the mappability regions? #
        ########################################################################
        # For size=1 use mpileup as in Autocorrelation!! #

        MOSDEPTH_PRECISION=${precision} mosdepth \
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

	# Create a frequency table
	zcat ${WORKDIR}/${SAMPLE}.${DEPTH}X.regions.bed.gz | \
	grep "$pattern_match" | \
	awk '{print $4}' | \
	sort -n | \
	uniq -c | \
	awk '{print $2"\t"$1}' | sort -n -k1,1 \
	 > ${WORKDIR}/${SAMPLE}.${downsampling_depth}.counts.txt


#SCRIPTDIR=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts/src/ # scWGA method
module load gcc/6.4.0 R/3.5.3
Rscript ${SCRIPTDIR}/GiniIndex.R $SAMPLE $WORKDIR $downsampling_depth
