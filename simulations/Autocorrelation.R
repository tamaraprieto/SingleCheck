#!/usr/bin/env Rscript

obtain.autocorrelation <- function(input){
genomecov <- input
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
return(autocorrelation)
}
