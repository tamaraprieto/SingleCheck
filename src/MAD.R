#!/usr/bin/env Rscript
# Calculate Coefficient of Variation from frequency table
library(tidyverse)
library(dplyr)
library(matrixStats)
args            = commandArgs(TRUE)
#countsFile = paste(args[2],"/",args[1],".",args[3],".counts.txt" , sep ="")
countsFile = paste(args[1],".contiguous.txt" , sep ="")
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE)
colnames(genomecov) = c("depth", "depth_fwd", "count")

lengthSeq = sum(genomecov$count)

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

genomecov = genomecov  %>% drop_na("depth_fwd") %>% 
		       mutate( c = depth-depth_fwd/meanDepth )

median_diffs = weightedMedian(genomecov$c,genomecov$count, ties = "weighted")

genomecov = genomecov  %>% mutate( d = abs (c - median_diffs) )

mad = weightedMedian(genomecov$d,genomecov$count, ties = "weighted")

print(mad)
MAD = data.frame(basename(args[1]),mad)
write.table(x=MAD,file=paste(dirname(args[1]),"/MAD.",basename(args[1]),".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
