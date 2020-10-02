#!/usr/bin/env Rscript
library(tidyr)
library(dplyr)

obtain.gini <- function(input,window_size) {
genomecov = input
colnames(genomecov) = c("depth", "count")

window_size=window_size

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
return(gini)
}
