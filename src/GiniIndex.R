#!/usr/bin/env Rscript
library(dplyr)
args            = commandArgs(TRUE)
#countsFile = paste(args[2],"/",args[1],".",args[3],".counts.txt" , sep ="")
countsFile = paste(args[1],".freqs.txt" , sep ="")
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE)
#colnames(genomecov) = c("depth", "count", "len")
colnames(genomecov) = c("depth", "count")

# calculate the cumulative sum of column 2
genomecov = genomecov %>% mutate(sumcount = cumsum(as.numeric(count)))

# This two lines are the same
lengthSeq = sum(genomecov$count)
#lengthSeq = as.numeric(genomecov$len[1])

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

first_formula_term = 2/(lengthSeq^2*(meanDepth))

genomecov = genomecov %>% rowwise() %>% mutate(first = ((sum(0:sumcount))-sum(0:(sumcount-count)))) %>% mutate(tosum=first*(depth-meanDepth))

second_formula_term = sum(genomecov$tosum)
gini = first_formula_term * second_formula_term
print(gini)
#write.table(x=gini,file=paste(args[2],"/","Gini.",args[1],".",args[3],".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
write.table(x=gini,file=paste(dirname(args[1]),"/Gini.",basename(args[1]),".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
