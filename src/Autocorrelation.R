#!/usr/bin/env Rscript
library(tidyr)
library(dplyr)
#library(matrixStats)
args            = commandArgs(TRUE)
countsFile = paste(args[1],".shiftedcov.txt" , sep ="")
alpha = as.numeric(args[2])
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE,colClasses = c("numeric", "numeric","numeric"))
colnames(genomecov) = c("depth", "depth_fwd", "count")

lengthSeq = sum(genomecov$count)

# Calculate the mean depth
#meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq
meanDepth = genomecov  %>% drop_na("depth") %>%
                       dplyr::select(depth, count) %>%
                       dplyr::mutate( c = depth*count ) %>%
                       dplyr::summarize(sum(c)/lengthSeq) %>%
		       as.numeric()

genomecov = genomecov  %>% drop_na("depth_fwd") %>%
		       drop_na("depth") %>%
		       dplyr::mutate( c = depth*depth_fwd*count )

first_term = (sum (genomecov$c)) / (lengthSeq - alpha)
second_term = meanDepth^2

autocorrelation = (first_term - second_term) / second_term

AUTOCORR = data.frame(basename(args[1]),autocorrelation)
write.table(x=AUTOCORR,file=paste(dirname(args[1]),"/Autocorrelation.",basename(args[1]),".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
