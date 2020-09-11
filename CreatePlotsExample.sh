#!/bin/sh

# SET UP VARIABLES
Samples_File=example/Samples.txt
export PATH=/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/scripts:$PATH

sample=$(head -n 1 $Samples_File)
path=$(dirname $sample)
size=10000000
delta=1000
rm ${path}/Autocorrelation.txt

for measurement in MAD Gini CV
do
rm ${path}/${measurement}.txt
while read sample 
do
name=$(basename $sample)
path=$(dirname $sample)
if [ "$measurement" == "CV" ];then
cat "${path}/Autocorrelation.${name}.${delta}.txt" | awk '{print "Autocorrelation\t"$0}' >> "${path}/Autocorrelation.txt"
fi
cat "${path}/${measurement}.${name}.${size}.txt" | awk -v measurement=$measurement '{print measurement"\t"$0}' >> "${path}/${measurement}.txt"
done < $Samples_File
done

cat ${path}/MAD.txt ${path}/Gini.txt ${path}/CV.txt ${path}/Autocorrelation.txt > ${path}/SingleCheckOutput.txt
echo "Output generated at ${path}/SingleCheckOutput.txt"
