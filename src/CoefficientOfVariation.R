#!/usr/bin/env Rscript
# Calculate Coefficient of Variation from frequency table

library(dplyr)
args            = commandArgs(TRUE)
#countsFile = paste(args[2],"/",args[1],".",args[3],".counts.txt" , sep ="")
countsFile = paste(args[1],".freqs.txt" , sep ="")
genomecov = read.table(countsFile,stringsAsFactors = FALSE, header = FALSE,colClasses = c("numeric", "numeric"))
colnames(genomecov) = c("depth", "count")

lengthSeq = sum(genomecov$count)

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

genomecov = genomecov  %>% mutate( tosum = (depth-meanDepth)^2 * count )

upper_term = sqrt(sum(genomecov$tosum)/(sum(genomecov$count)-1))
cv = upper_term / meanDepth
print(cv)
cv = data.frame(basename(args[1]),cv)
write.table(x=cv,file=paste(dirname(args[1]),"/CV.",basename(args[1]),".txt",sep=""),quote=FALSE,sep="\t",row.names=FALSE,col.names=FALSE)
