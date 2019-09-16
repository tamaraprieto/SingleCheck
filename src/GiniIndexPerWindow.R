#!/usr/bin/env Rscript
library(plyr)
library(dplyr)
library(ineq)

# Samtools bedcov returns the sum of per-base read depths for each genomic region!!
# File example <sample>.<seqdepth>X.<windowsize>bp.bed
#1    0    500000    2498679
#1    500000    1000000    3619972
#1    1000000    1500000    3781800
#1    1500000    2000000    3184141

args            = commandArgs(TRUE)
sample=args[1]
workdir=args[2]
seqdepth=args[3]
windowsize=args[4]

#sample="Wangetal.BulkNormal"
#seqdepth="1"
#windowsize="1000"
#workdir="/mnt/netapp2/posadalab2/uvibetpf/SCCoverageUniformity/RESULTS/HDF/"

countsFile = paste(workdir,"/",sample,".",seqdepth,"X.",windowsize,"bp.bed" , sep ="")
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE)
colnames(genomecov) = c("contig", "start","end", "WindowPerbasedepthSum")
genomecov = genomecov %>% mutate(meancov=as.numeric(WindowPerbasedepthSum)/as.numeric(windowsize))
gini=ineq(as.numeric(genomecov$meancov),type="Gini")
print(gini)
write.table(x=gini,file=paste(workdir,"/","GiniPerWindow.",windowsize,"bp.",sample,".",seqdepth,".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
