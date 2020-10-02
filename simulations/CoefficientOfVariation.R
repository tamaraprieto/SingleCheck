#!/usr/bin/env Rscript

obtain.cv <- function(input) { 
genomecov <- input
colnames(genomecov) = c("depth", "count")

lengthSeq = sum(genomecov$count)

# Calculate the mean depth
meanDepth = sum(as.numeric(genomecov$depth)*as.numeric(genomecov$count))/lengthSeq

genomecov = genomecov  %>%
	dplyr::mutate( tosum = (depth-meanDepth)^2 * count )

upper_term = sqrt(sum(genomecov$tosum)/(sum(genomecov$count)-1))
cv = upper_term / meanDepth
return(cv)
}
