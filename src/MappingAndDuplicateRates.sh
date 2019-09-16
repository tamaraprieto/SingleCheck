#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 00:30:00
#SBATCH --mem 20G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

#downsampling_depth=$2
#bam_suffix=".downsampled"

#module purge
#module load picard/2.18.14
#java -jar $EBROOTPICARD/picard.jar \
#        CollectAlignmentSummaryMetrics \
#        R=${RESDIR}/${REF}.fa \
#        I=${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}X.bam \
#        O=${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}.alignment_summary_metrics_all.txt

#awk '/^CATEGORY/ {split($0,header);n=1;next; } {if(n!=1) next; for(i=2;i<=NF;++i) printf("%s\t%s\t%s\n",$1,header[i],$i);}' ${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}.alignment_summary_metrics_all.txt | column -t | grep -e "^UNPAIRED" -e "^PAIR" > ${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}.alignment_summary_metrics.txt

module load gcccore/6.4.0 samtools/1.9
#samtools flagstat \
#	${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}X.bam > \
#	${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}.flagstat.txt

#filter=""
filter=.mappedtoautosomes
AUTOSOMES=$(cat ${RESDIR}/${REF}.fai | head -n 21 | awk '{print $1}' | tr -s "\n" " " | sed 's/ $//')
for RG in `samtools view -H /mnt/netapp1/Store_uvibetpf/Single-Cell/RESULTS/${SAMPLE}.dedup.bam | grep "^@RG" | awk '{print $2}' | sed 's/ID://'`
do
samtools view -bh -r ${RG} /mnt/netapp1/Store_uvibetpf/Single-Cell/RESULTS/${SAMPLE}.dedup.bam ${AUTOSOMES} > ${WORKDIR}/${SAMPLE}.dedup.${RG}${filter}.bam
samtools index ${WORKDIR}/${SAMPLE}.dedup.${RG}${filter}.bam
samtools flagstat ${WORKDIR}/${SAMPLE}.dedup.${RG}${filter}.bam > ${WORKDIR}/${SAMPLE}.RG-${RG}${filter}.flagstat.txt
done


aligned_bases=$(samtools view ${WORKDIR}/${SAMPLE}.dedup.${RG}${filter}.bam | awk '{sum+=length($10)}END{print sum}')
aligned_soft_bases=$(samtools view ${WORKDIR}/${SAMPLE}.dedup.${RG}${filter}.bam | cut -f10 | awk '{total+=length}END{print total}')
mapped_bases=$(awk -v al=$aligned_bases -v alsoft=$aligned_soft_bases 'BEGIN{print al-alsoft}')
