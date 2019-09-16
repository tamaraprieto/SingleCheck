#!/usr/bin/env Rscript
args            = commandArgs(TRUE)
sample		= args[[1]]
depth		= args[[2]]
size   		= args[[3]]
workdir		= args[[4]]

library(data.table)
file_name=paste(workdir,sample, ".", depth,"X.", size, "bp.bed", sep="")
genome <-fread(file_name, header = F, colClasses = c("factor", "numeric", "numeric", "numeric"), col.names = c("chr","start", "end", "counts"))

library(GeneCycle)
#spectrum(genome$counts, plot=TRUE)
periodogram(genome$counts, method = "smooth", plot=TRUE)
test<-periodogram(genome$counts, method = "smooth")
library(ggplot2)
mydata<-cbind(test$freq,test$spec)
colnames(mydata) <- c("freq","spec")
ggplot(data=as.data.frame(mydata)) +
	geom_line(aes(x=freq,y=sqrt(spec))) +
        labs(x="Frequency (1/bp)", y="Amplitude")
ggsave(paste(workdir,"Periodogram.",sample,".",depth,".",size,".png",sep=""))
	#coord_cartesian(ylim = c(-100, 100000), expand = FALSE) +

#avgp(genome$counts, title=sample)

