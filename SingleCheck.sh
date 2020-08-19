#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 02:00:00
#SBATCH --mem 40G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

echo "> Loading modules"
module restore SC_QC

echo "> PICARD COLLECT ALIGNMENT METRICS"
java -jar $PICARD CollectAlignmentSummaryMetrics \
        R=${RESDIR}/${REF}.fa \
        I=${WORKDIR}/${SAMPLE}.dedup.bam \
        O=${WORKDIR}/${SAMPLE}.alignment_summary_metrics_all.txt \
        MAX_INSERT_SIZE=1000 \
        ADAPTER_SEQUENCE=null \
        ADAPTER_SEQUENCE=GCTGTCAGTTAA,TTAACTGACAGCAGGAATCCCACT,GTGAGTGATGGTTGAGGTAGTGTGGAG,CTCCACACTACCTCAACCATCACTCAC,TGTGTTGGGTGTGTTTGG,CCAAACACACCCAACACA,TGTTGTGGGTTGTGTTGG,CCAACACAACCCACAACA,TGTGTTGGGTGTGTTTGG,CCAAACACACCCAACACA
awk '/^CATEGORY/ {split($0,header);n=1;next; } {if(n!=1) next; for(i=2;i<=NF;++i) printf("%s\t%s\t%s\n",$1,header[i],$i);}' ${WORKDIR}/${SAMPLE}.alignment_summary_metrics_all.txt | column -t | grep -e "^UNPAIRED" -e "^PAIR" > ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt

echo "> METAPHYLER"
samtools view -f 0x4 ${WORKDIR}/${SAMPLE}.dedup.bam | awk '{OFS="\t"; print ">"$1"\n"$10}' > ${WORKDIR}/${SAMPLE}.unmapped.fasta
~/apps/Metaphyler/MetaPhylerSRV0.115/metaphyler.pl 2 ${WORKDIR}/${SAMPLE}.unmapped.fasta ${WORKDIR}/${SAMPLE}

echo "> DOWNSAMPLE"
subsampling_depth=5
raw_reads=$(grep "TOTAL_READS" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt | awk '{print $3}')
# Get the number of bases which are aligned, soft-clipped or unmapped (only count only primary aligments)
aligned_soft_bases=$(samtools view -F 256 $WORKDIR/$SAMPLE.dedup.bam | cut -f10 | awk '{total+=length}END{print total}')
# Get the number of bases which are hard-clipped
hard_bases=$(samtools view $WORKDIR/$SAMPLE.dedup.bam | cut -f6 | grep H | sed 's/\([0-9]*\)\([A-Z]\)/\1\2\n/g' | grep -v "^$" | grep H | sed 's/H//' | awk '{sum+=$1}END{print sum}')
if [ -z "$hard_bases" ];then
	hard_bases=0
fi
raw_bases=$(($aligned_soft_bases + $hard_bases))
genome_length=$(cat ${RESDIR}/${REF}.fai | cut -f2 | awk '{sum+=$1}END{print sum}')
sequencing_depth=$(bc -l <<< "scale=4; $raw_bases / $genome_length")

## Avoiding subsampling when coverage is lower than 0.1
if [ $(echo "$sequencing_depth < $subsampling_depth" | bc) -eq 1 ]; then
        ln -s ${WORKDIR}/${SAMPLE}.dedup.bam ${WORKDIR}/${SAMPLE}.dedup.ps.bam
        echo "Sequencing depth is lower than "${subsampling_depth}": "${sequencing_depth}". No need to downsample"
	preseq_inference=${sequencing_depth}
else
	## Calculating subsampling probability
	probability=`bc -l <<< "scale=3; $subsampling_depth / $sequencing_depth"`
	echo "Downsampling probability: "$probability
	preseq_inference=${subsampling_depth}
	## Selecting a downsampling strategy
	if [ "$raw_reads" -gt "50000" ]
	then
	        strategy="HighAccuracy"
	        echo "Downsampling following "${strategy}" strategy. From "${sequencing_depth}"X to "${subsampling_depth}"X."
	# In case sequencing depth is higher than 2X (probability will be higher than 0.05) too much memory is required and we should avoid wasting time (although we will lose accuracy)
	elif [ $(echo " $probability > 0.05 " | bc) -eq 1 ];then
	        strategy="ConstantMemory"
	        echo "Downsampling following "${strategy}" strategy. From "${sequencing_depth}"X to "${subsampling_depth}"X."
	else
	        strategy="Chained"
	        echo "Downsampling following "${strategy}" strategy. From "${sequencing_depth}"X to "${subsampling_depth}"X."
	fi
	java -jar $PICARD DownsampleSam \
	        INPUT=${WORKDIR}/${SAMPLE}.dedup.bam \
	        OUTPUT=${WORKDIR}/${SAMPLE}.dedup.ps.bam \
	        RANDOM_SEED=1 \
	        PROBABILITY=${probability} \
	        STRATEGY=$strategy
fi

echo "> PRESEQ"
~/apps/PreSeq/preseq_v2.0/bam2mr -v -o ${WORKDIR}/${SAMPLE}.mr ${WORKDIR}/${SAMPLE}.dedup.ps.bam
~/apps/PreSeq/preseq_v2.0/preseq gc_extrap -v -o ${WORKDIR}/${SAMPLE}_inferredcov.txt ${WORKDIR}/${SAMPLE}.mr

echo "> BEDTOOLS GENOMECOV"
bedtools genomecov \
        -ibam ${WORKDIR}/${SAMPLE}.dedup.bam | grep "^genome" > ${WORKDIR}/${SAMPLE}_genome.bed

echo "> FILTER"
# 1284: remove not primary alignments, unmapped and duplicates
samtools view -F 1284 -b ${WORKDIR}/${SAMPLE}.dedup.bam > ${WORKDIR}/${SAMPLE}.flt.bam
samtools index ${WORKDIR}/${SAMPLE}.flt.bam

echo "> BEDTOOLS FOR LORENZ"
bedtools genomecov -d \
        -ibam ${WORKDIR}/${SAMPLE}.flt.bam | grep "^genome" \
	| sort -n | awk -v SAMPLE=${SAMPLE} -v dir=${WORKDIR}
	'BEGIN{sum=0}{sum+=$1; print sum}END{print sum >
	dir"TotalCumCov."SAMPLE }' \
	> ${WORKDIR}/${SAMPLE}_genome.bed

# Get lorenz curves by windows
echo "> LORENZ CURVES"
python /home/uvi/be/tpf/apps/pysamstats/scripts/pysamstats \
	-t coverage_ext_binned \
	${WORKDIR}/${SAMPLE}.flt.bam \
	--fasta ${RESDIR}/${REF}.fa \
	--window-size=1000000 \
	--omit-header | cut -f4 | sort -n | \
	awk -v SAMPLE=${SAMPLE} -v dir=${WORKDIR} 'BEGIN{sum=0}{sum+=$1; print sum}END{print sum > dir"TotalCumCov."SAMPLE }' > ${WORKDIR}/${SAMPLE}_pysamstats.txt

totalcumcov=$(head -1 ${WORKDIR}/TotalCumCov.${SAMPLE})
xmax=$(awk '$1 > 0 {print $0}' ${WORKDIR}/${SAMPLE}_pysamstats.txt | wc -l)
awk -v SAMPLE=${SAMPLE} -v TOTALCUMCOV=$totalcumcov -v XMAX=$xmax 'BEGIN{num=1}{ if ($1 > 0) {print num/XMAX"\t"$1/TOTALCUMCOV"\t"SAMPLE; num+=1}}' ${WORKDIR}/${SAMPLE}_pysamstats.txt > ${WORKDIR}/${SAMPLE}_LorenzCurve.txt
#awk -v SAMPLE=${SAMPLE} -v TOTALCUMCOV=$totalcumcov -v XMAX=$xmax 'BEGIN{num=1}{ if ($1 > 0) {print num/XMAX"\t"$1/TOTALCUMCOV"\t"SAMPLE; num+=1} else {print } }' ${WORKDIR}/${SAMPLE}_pysamstats.txt > ${WORKDIR}/${SAMPLE}_LorenzCurve.txt

echo "> CREATE QC FILE"
rm ${WORKDIR}/${SAMPLE}_QC.txt
alignments=$(samtools view -c ${WORKDIR}/${SAMPLE}.dedup.bam)
unmapped=$(samtools view -cf 4 ${WORKDIR}/${SAMPLE}.dedup.bam)
# 2308 are reads unmapped,secondary and supplementary; -F is equivalent to grep -v
primary=$(samtools view -cF 2308 ${WORKDIR}/${SAMPLE}.dedup.bam)
# 320:first read in pair, secondary alignment
primarynonunique_1=$(samtools view -f 320 ${WORKDIR}/${SAMPLE}.dedup.bam | awk '{print $1}' | sort -h | uniq -c | wc -l)
# 384:second in pair, not primary alignment
primarynonunique_2=$(samtools view -f 384 ${WORKDIR}/${SAMPLE}.dedup.bam | awk '{print $1}' | sort -h | uniq -c | wc -l)
# unique are those reads which only map to one region in the genome
unique=$((${primary}-${primarynonunique_1}-${primarynonunique_2}))
# 1024: read is PCR or optical duplicate
duplicate=$(samtools view -cf 1024 ${WORKDIR}/${SAMPLE}.dedup.bam)
MT=$(samtools idxstats ${WORKDIR}/${SAMPLE}.dedup.bam | grep -e "^MT" -e "^chrM" | awk '{print $3}')
genome=$(cut -f 5 ${WORKDIR}/${SAMPLE}_genome.bed | head -1)
breadth=$(head -1 ${WORKDIR}/${SAMPLE}_genome.bed | awk '{print (1-$5)*100}')
#genome_length=$(head -1 ${WORKDIR}/${SAMPLE}_genome.bed | awk '{print $4}')
adapter=$(grep "PCT_ADAPTER" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt | awk '{print $3*100}') # Although the variable name is PCT_ADAPTER, it is proportion, so I multiply by 100

# Count supplementary alignments
chimeric_flag=$(samtools view -cf 2048 ${WORKDIR}/${SAMPLE}.dedup.bam)
bwa_mem=$(samtools view -H ${WORKDIR}/${SAMPLE}.dedup.bam | grep -c "bwa mem")
if [ $bwa_mem -gt 0 ]; then
# Select first in pair reads (64)
chimeric_1=$(samtools view -F 64 ${WORKDIR}/${SAMPLE}.dedup.bam | grep "SA:Z" | awk '{print $1}' | sort -k1,1 | uniq | wc -l)
# Select second in pair reads (128)
chimeric_2=$(samtools view -F 128 ${WORKDIR}/${SAMPLE}.dedup.bam | grep "SA:Z" | awk '{print $1}' | sort -k1,1 | uniq | wc -l)
chimeric=$(echo "$chimeric_1+$chimeric_2" | bc -l)
elif [ $chimeric_flag -eq 0 ]
then
chimeric="NA"
else
chimeric=$(samtools view -cf 2048 ${WORKDIR}/${SAMPLE}.dedup.bam)
fi


value=$( grep -c "UNPAIRED" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt )
if [ $value -gt 0 ]
then
	chimerapairs="NA"
else
	chimerapairs=$(grep "PCT_CHIMERAS" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt | awk '{print $3*100}') # Although the variable name is PCT_ADAPTER, it is proportion, so I multiply by 100
fi
#chimera=$(grep "PCT_CHIMERAS" ${WORKDIR}/${SAMPLE}.alignment_summary_metrics.txt | awk '{print $3*100}') # Although the variable name is PCT_ADAPTER, it is proportion, so I multiply by 100
class=$(awk '{if ($1 !~ "{") print $0}' ${WORKDIR}/${SAMPLE}.genus.tab | grep -v "^@" | awk '{if ($5 >= 98) print $1}' | tr -s '\n' ',' | sed 's/,$/\n/')

echo "Variables set up"

awk -v sample=${SAMPLE} -v treads=${raw_reads} -v tbases=${raw_bases} -v seqdepth=${sequencing_depth} -v talign=${alignments} -v unique=${unique} -v unmapped=${unmapped} -v dup=${duplicate} -v mt=${MT} -v bact=${class} -v breadth=${breadth} -v genlen=${genome_length} -v adapt=${adapter} -v suppl=${chimeric} -v chimerapairs=${chimerapairs} -v preseq_inf=${preseq_inference} -F $'\t' 'BEGIN{OFS=FS; print sample,treads,tbases/1000000000,seqdepth,unique/treads*100,unmapped/treads*100,adapt,dup/(treads-unmapped)*100,chimeric/treads*100,chimerapairs,mt/(treads-unmapped)*100,bact,breadth,breadth*tbases/genlen,preseq_inf}' > ${WORKDIR}/${SAMPLE}_QC.txt

echo "> FINISHED"
