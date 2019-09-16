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


#readlength=100
readlength=151
suffix="."${readlength}"readlengthfixed"
# suffix=".rawsequencingdepth" #scWGA paper
#file_extension=".sorted"
file_extension=".downsampled"
#file_extension=".dedup" #scWGA paper

module purge
module load picard/2.18.14
java -jar $EBROOTPICARD/picard.jar \
	CollectAlignmentSummaryMetrics \
        R=${RESDIR}/${REF}.fa \
        I=${WORKDIR}/${SAMPLE}${file_extension}.bam \
        O=${WORKDIR}/${SAMPLE}.alignment_summary_metrics_all.txt
# Transform output format from alignment summary
awk '/^CATEGORY/ {split($0,header);n=1;next; } {if(n!=1) next; for(i=2;i<=NF;++i) printf("%s\t%s\t%s\n",$1,header[i],$i);}' ${WORKDIR}/${SAMPLE}.alignment_summary_metrics_all.txt | column -t | grep -e "^UNPAIRED" -e "^PAIR" > ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt

module load gcc/6.4.0 samtools/1.9
# Get the number of bases which are aligned, soft-clipped or unmapped
aligned_softclipped_unmapped_bases=$(samtools view -F 256 ${WORKDIR}/${SAMPLE}${file_extension}.bam | cut -f10 | awk '{total+=length}END{print total}')
hardclipped_bases=$(samtools view ${WORKDIR}/${SAMPLE}${file_extension}.bam | cut -f6 | sed 's/\([0-9]*\)\([A-Z]\)/\1\2\n/g' | grep -v "^$" | grep H | sed 's/H//' | awk '{sum+=$1}END{print sum}')
#raw_reads=$(grep "TOTAL_READS" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt | awk '{print $3}')
raw_bases=$(awk -v a=$aligned_softclipped_unmapped_bases -v b=$hardclipped_bases 'BEGIN{print a+b}')
genome_length=$(cat ${RESDIR}/${REF}.fai | cut -f2 | awk '{sum+=$1}END{print sum}')
#sequencing_depth=$(awk -v genomelength=$genome_length -v rawreads=$raw_reads -v readlen=$readlength 'BEGIN{print rawreads*readlen/genomelength}')
sequencing_depth=$(awk -v genomelength=$genome_length -v rawbases=$raw_bases 'BEGIN{print rawbases/genomelength}')
echo $SAMPLE $sequencing_depth > ${WORKDIR}/${SAMPLE}${suffix}.seqdepth.txt


