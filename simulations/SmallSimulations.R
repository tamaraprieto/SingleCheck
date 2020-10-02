library(tidyverse)
library(tidyr)
library(dplyr)
library(matrixStats)
library(gtools)
library(ggplot2)
library(ggpubr)
library(sitools)
source("example/CoefficientOfVariation.R")
source("example/GiniIndex.R")
source("example/MAD.R")
source("example/Autocorrelation.R")


CalculateStatistics <- function(coverage_array, window_size) {

# last window removed if not complete
coverage_array_bywindow <- running(coverage_array, width = window_size, by = window_size, fun = mean,  na.rm = TRUE, simplify = TRUE)

Coverage_table <- coverage_array_bywindow %>%
  as.data.frame() %>%
  group_by_all() %>%
  summarise(COUNT = n()) %>%
  as.data.frame()
  
GINI <- Coverage_table %>%
  obtain.gini(window_size = window_size)

CV <- Coverage_table %>%
  obtain.cv()

alpha <- window_size + 1

# MAD

pos <- 2  # Measure always consecutive windows
delayed_coverage_array_bywindow<- coverage_array_bywindow[pos:length(coverage_array_bywindow)]
length(delayed_coverage_array_bywindow) = length(coverage_array_bywindow)
MAD <- cbind(coverage_array_bywindow, delayed_coverage_array_bywindow) %>%
  as.data.frame() %>%
  group_by_all() %>%
  summarise(COUNT = n()) %>%
  as.data.frame() %>%
  obtain.MAD()

# AUTOCORRELATION

pos <- alpha + 1 # if alpha is 1 given that R does not use 0-based for vectors, it will copy the same vector
delayed_coverage_array <- coverage_array[pos:length(coverage_array)]
length(delayed_coverage_array) = length(coverage_array)
AUTOCORRELATION <- cbind(coverage_array, delayed_coverage_array) %>%
  as.data.frame() %>%
  group_by_all() %>%
  summarise(COUNT = n()) %>%
  as.data.frame() %>%
  obtain.autocorrelation()

myoutput <- list(GINI, CV, MAD, AUTOCORRELATION)
return(myoutput)

}

ObtainPlotsStatistics <- function (mycoverage_array){
window_sizes <- c(1,2,3,4,7,15,25,50,100,200,300,400,500,1000,2000,3000,5000,10000,25000,50000)
Values <- sapply(window_sizes, FUN = CalculateStatistics, coverage_array = mycoverage_array)
rownames(Values) <- c("GINI","CV","MAD","AUTOCORRELATION")
colnames(Values) <- window_sizes
newValues <- as.data.frame(t(Values))
newValues$windows <- rownames(newValues)
Statistics <- pivot_longer(data = newValues, cols = c(GINI,CV,MAD,AUTOCORRELATION)) %>%
  as.data.frame()
  
Statistics$name <- factor(as.factor(Statistics$name), levels = c("GINI","CV","MAD","AUTOCORRELATION"))

StatisticsPlot <-  ggplot(Statistics,aes(x=as.numeric(windows), y=as.numeric(value))) +
  geom_line() +
  geom_point() +
  scale_x_continuous(trans = 'log10', breaks=as.numeric(unique(window_sizes)), labels =paste( f2si(as.numeric(window_sizes)),"bp",sep="")) +
  facet_wrap(. ~ name, scales = "free", nrow = 1) +
  labs(x="Window size or Delta", y="") +
  theme(legend.position = "bottom", axis.text.x = element_text(angle = 90, hjust = 1,vjust = 0.5))

CoveragePlot<- mycoverage_array %>%
  as.data.frame() %>%
  rownames_to_column() %>%
  add_column(y = seq(1:length(mycoverage_array))) %>%
  ggplot(aes(y=mycoverage_array, x=y)) +
  geom_point(col="purple") +
  #geom_line(col="purple") +
  labs(x="Positions", y="Counts")

FinalPlot<- ggarrange(plotlist = list(CoveragePlot,StatisticsPlot), ncol = 1)
sample <- gsub(".*_","",deparse(substitute(mycoverage_array)))
ggsave(plot = FinalPlot, filename = paste("/Users/tama/Downloads/SimulationsCoverage",sample,".png", sep=""), width = 30, height = 9)
}


# CREATE FLAT COVERAGE PROFILE
N=1000
coverage_pattern=c(4,4,4,4,4,4,4,4)
coverage_array_perfect <- rep(coverage_pattern, N)
ObtainPlotsStatistics(mycoverage_array = coverage_array_perfect)



# CREATE STRUCTURED COVERAGE PROFILE
N=1000
coverage_pattern=c(4,4,4,4,5,5,5,5)
coverage_array_sc <- rep(coverage_pattern, N)
ObtainPlotsStatistics(mycoverage_array = coverage_array_sc)


# CREATE A BULK (LACK OF STRUCTURE)
N=100000
coverage_array_bulk <- rpois(n = N, lambda = 10)
ObtainPlotsStatistics(mycoverage_array = coverage_array_bulk)


# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS TOGETHER)
N=100000
amplicon_length  <- 400
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
mean_normal <- rpois(n=1, lambda = 10)
amplicon <- rnorm(n = amplicon_length, mean = mean_normal)
previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_sc_Realistic <- previous_amplicons
ObtainPlotsStatistics(mycoverage_array = coverage_array_sc_Realistic)

# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS SEPARATED)

