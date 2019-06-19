#!/usr/bin/env Rscript
args            = commandArgs(TRUE)
depth		= args[[1]]
workdir         = args[[2]]

library(data.table)
library(plyr)
library(flexmix)

file_name=paste(workdir,"AllSamples.",depth,".counts.txt", sep="")
genome <-fread(file_name, header = F, colClasses = c("factor", "integer", "numeric", "numeric"), col.names = c("Sample","Depth", "Counts", "Genome length"))
genome$`Percentage of genome` <- genome$Counts/genome$`Genome length`*100
genome$Sample <- mapvalues(genome$Sample, from = levels(genome$Sample), to = c("single cell 1","single cell 2", "single cell 3", "single cell 4","healthy bulk","tumor bulk"))

# dcast is like the opposite function of melt
counts<-dcast(genome, Depth ~ Sample, value.var = "Percentage of genome")
counts[is.na(counts)] <- 0
distance_matrix<-KLdiv(as.matrix(counts[,c(2,3,4,5,6,7)]))
longData<-melt(distance_matrix)
write.table(x=longData,file=paste(workdir,"KLdistances.",depth,".txt",sep=""),quote=FALSE, sep="\t", col.names=FALSE,row.names=FALSE)

