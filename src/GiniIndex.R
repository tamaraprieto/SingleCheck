#!/usr/bin/env Rscript
library(tidyr)
library(dplyr)
args            = commandArgs(TRUE)
#countsFile = paste(args[2],"/",args[1],".",args[3],".counts.txt" , sep ="")
countsFile = paste(args[1],".freqs.txt" , sep ="")
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE,colClasses = c("numeric", "numeric"))
#colnames(genomecov) = c("depth", "count", "len")
colnames(genomecov) = c("depth", "count")

window_size=as.numeric(args[2])

# calculate the cumulative sum of column 2
genomecov = genomecov %>%
	dplyr::mutate(sumcount = cumsum(as.numeric(count))) %>%
        dplyr::mutate(depth=round(depth*window_size)) # this line is to avoid problems with floats of averaging 

# This two lines are the same
lengthSeq = sum(genomecov$count)
#lengthSeq = as.numeric(genomecov$len[1])

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

first_formula_term = 2/(lengthSeq^2*(meanDepth))

genomecov = genomecov %>% rowwise() %>%
	dplyr::mutate(first = ((sum(0:sumcount))-sum(0:(sumcount-count)))) %>%
	dplyr::mutate(tosum=first*(depth-meanDepth))

second_formula_term = sum(genomecov$tosum)
gini = first_formula_term * second_formula_term
print(gini)
gini = data.frame(basename(args[1]),gini)
write.table(x=gini,file=paste(dirname(args[1]),"/Gini.",basename(args[1]),".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
