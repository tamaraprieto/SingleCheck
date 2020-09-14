#!/bin/bash

#SamplesFile=example/Samples.txt
SamplesFile=$1
path=$(dirname "$SamplesFile")

printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "Sample" "Sequenced bases" "Original sequencing depth" "Bin size" "Delta" "% of unmapped reads" "% of reads mapped to the mitochondria" "Potential contaminants" "Breadth" "Autocorrelation" "Coefficient of variation" "Gini index" > ${path}/SingleCheck.txt
while read sample 
do
name=$(basename $sample)
if [ ! -f "${sample}.SingleCheck.txt" ];then
rm -f ${path}/SingleCheck.txt
echo "${sample}.SingleCheck.txt does not exist"
exit 1
fi
cat ${sample}.SingleCheck.txt >> ${path}/SingleCheck.txt
done < $SamplesFile

echo "Output generated at ${path}/SingleCheck.txt"
