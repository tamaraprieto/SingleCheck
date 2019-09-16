#!/usr/bin/env Rscript
args            = commandArgs(TRUE)
dataset            = args[[1]]
size		= args[[2]]
setwd(paste("/mnt/netapp1/posadalab/APPS/ginkgo/uploads/",dataset,sep=""))

genome            = "hg19"
bm                = paste("variable_",size,"_150_bwa",sep="")
pseudoautosomal = ""

raw = read.table('data', header=TRUE, sep="\t")
l = dim(raw)[1] # Number of bins
w = dim(raw)[2] # Number of samples
normal = sweep(raw+1, 2, colMeans(raw+1), '/')
cellIDs <- colnames(normal)

# Calculate MAD for selected cells
a = matrix(0, length(cellIDs), 1)
rownames(a) <- colnames(normal[,cellIDs])
for(i in 1:length(cellIDs)){
        cell = cellIDs[i]
        #column 1: calculate MAD on subtracted values of bins that are right next to each other
        a[i, 1] = mad(normal[-1    , cell] - normal[1:(l-1), cell])   # same as diff()
    }
a
write.table(x=paste(a,size, sep="\t"),file=paste("../MAD.",size,".txt",sep=""),col.names=FALSE,quote=FALSE, sep="\t") # HDF
#write.table(x=a,file=paste("MAD.",dataset,".txt",sep=""),col.names=FALSE,quote=FALSE, sep="\t") # WANG

