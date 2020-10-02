#!/usr/bin/env Rscript

obtain.MAD <- function(input) { 
genomecov = input
colnames(genomecov) = c("depth", "depth_fwd", "count")

lengthSeq = sum(genomecov$count)

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

genomecov = genomecov  %>% drop_na("depth_fwd") %>% 
		       mutate( c = (depth-depth_fwd)/meanDepth )

median_diffs = weightedMedian(genomecov$c,genomecov$count, ties = "weighted")

genomecov = genomecov  %>% mutate( d = abs (c - median_diffs) )

mad = weightedMedian(genomecov$d,genomecov$count, ties = "weighted")

return(mad)

}
