#!/bin/bash

# SET UP VARIABLES
Samples_File=example/Samples.txt
path=$(dirname "$Sample_File")
echo $path

rm -f ${path}/SingleCheck.txt
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "Sample" "Sequenced bases" "Original sequencing depth" "Bin size" "Delta" "% of unmapped reads" "% of reads mapped to the mitochondria" "Potential contaminants" "Breadth" "Autocorrelation" "Coefficient of variation" "Gini index" > ${NAME}.SingleCheck.txt
while read sample 
do
name=$(basename $sample)
if [ ! -f "${sample}.SingleCheck.txt" ];then
rm -f ${path}/SingleCheck.txt
echo "${sample}.SingleCheck.txt does not exist"
exit 1
fi
cat ${sample}.SingleCheck.txt >> ${path}/SingleCheck.txt
done < $Samples_File

echo "Output generated at ${path}/SingleCheckOutput.txt"
