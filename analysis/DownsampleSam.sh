#!/bin/sh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --mail-user tamara.prieto.fernandez@gmail.com
#SBATCH --mail-type FAIL
#SBATCH --cpus-per-task 1
#SBATCH -t 10:00:00
#SBATCH --mem 100G

source ReadConfig.sh $1
SAMPLE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" ${ORIDIR}/${SAMPLELIST})
echo $SAMPLE

bam_suffix=".sorted" # WANG and HUANG
#bam_suffix=".downsampled" # HDF

# Downsample to the lowest depth?
#downsampling_depth=$(awk '{print $2}' ${WORKDIR}/${suffix}.seqdepths.txt  | sort -n | head -n 1)
downsampling_depth=$2

#read_length=100 # WANG
#read_length=125 # HUANG-BULK
#read_length=150 # HUANG-MB-PP
#read_length=151 HDF
if [ -z "$3" ]
  then
    echo "No read length supplied"
    exit
else
    read_length=$3
fi
suffix="."${read_length}"readlengthfixed"
sequencing_depth=$(awk '{print $2}' ${WORKDIR}/${SAMPLE}${suffix}.seqdepth.txt)
echo $SAMPLE $sequencing_depth

# Calculating downsampling probability
# default awk decimal places 6
probability=`bc -l <<< "scale=10; $downsampling_depth / $sequencing_depth"`
#strategy=HighAccuracy
strategy=ConstantMemory # WANG and HUANG
echo "Downsampling following "${strategy}" strategy. From "${sequencing_depth}"X to "${downsampling_depth}"X."
if [[ ! -z $(awk -v prob=$probability 'BEGIN{if (prob > 1) print "Lowest sequencing than downsampling selected"}') ]]
then
exit
fi
# Reads from the same template (read-pairs,secondary and supplementary) are all either kept or discarded as a unit, with the goal of retaining reads from PROBABILITY * input templates. The results will contain approximately PROBABILITY * input reads, however for very small PROBABILITIES this may not be the case.
# Take the exponential of the number
num=$(printf %e ${probability} | fold -w1 | tail -n 1)
# Add -2 to the exponential
accuracy=$(awk -v num=$num 'BEGIN{print 0.01*10^-num}')
echo "Downsampling following "${strategy}" strategy. From "${sequencing_depth}"X to "${downsampling_depth}"X. Downsampling probability: "$probability". Accuracy: "${accuracy}
# First time I ran it was without CREATE_INDEX=false so I did not created the indexed files
module load picard/2.18.14
java -jar $EBROOTPICARD/picard.jar DownsampleSam \
	INPUT=${WORKDIR}/${SAMPLE}${bam_suffix}.bam \
	OUTPUT=${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}X.bam \
	RANDOM_SEED=1 \
	PROBABILITY=${probability} \
	STRATEGY=$strategy \
	CREATE_INDEX=true \
	ACCURACY=$accuracy

## Remove unplaced scaffolds
## We performed downsampling based on the total number of reads sequenced but now we want to check the uniformity on the autosomes and sex chromosomes.
## We will interrogate uniformity only in diploid chromsomes
## We keep XX in females but avoid it in males
## Careful!!!For HDF I used also chromosome X
#if [ "$GENDER" = "XX" ]
#then
#chr_num=23
#else
#chr_num=22
#fi 
#chrom_to_keep=$(cat ${RESDIR}/${REF}.fai | head -n ${chr_num} | awk '{print $1}' | tr -s "\n" " " | sed 's/ $//')
#module load gcc/6.4.0 samtools/1.9
#samtools view -hb ${WORKDIR}/${SAMPLE}${bam_suffix}.${downsampling_depth}X.bam ${chrom_to_keep} > ${WORKDIR}/${SAMPLE}.${downsampling_depth}X.filtered.bam
