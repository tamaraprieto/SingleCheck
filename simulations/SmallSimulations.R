library(tidyverse)
library(tidyr)
library(dplyr)
library(matrixStats)
library(ggplot2)
library(ggpubr)
library(sitools)
library(gtools)
library(reshape2)
source("simulations/CoefficientOfVariation.R")
source("simulations/GiniIndex.R")
source("simulations/MAD.R")
source("simulations/Autocorrelation.R")

in_dir="/Users/tama/Google Drive/Tamara Prieto/Thesis/FilesToCreateFigures/"
out_dir="/Users/tama/Google Drive/Tamara Prieto/Thesis/Figures/"



#coverage_array <- coverage_array_bulk
#window_size <- 1
CalculateStatistics <- function(coverage_array, window_size) {
  
  print (window_size)
  # last window removed if not complete
  coverage_array_bywindow <- running(coverage_array, width = as.integer(window_size), by=as.integer(window_size), fun = mean,
                                     na.rm = TRUE, simplify = TRUE)
  
  Coverage_table <- coverage_array_bywindow %>%
    as.data.frame() %>%
    group_by_all() %>%
    summarise(COUNT = n()) %>%
    as.data.frame()
  
  GINI <- Coverage_table %>%
    obtain.gini(window_size = window_size)
  
  CV <- Coverage_table %>%
    obtain.cv()
  
  alpha <- as.integer(window_size) + 1
  
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
  
  pos <- as.integer(alpha) + 1 # if alpha is 1 given that R does not use 0-based for vectors, it will copy the same vector
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

ObtainPlotsStatistics <- function (coverage_array, window_sizes){

  sample <- gsub(".*_","",deparse(substitute(coverage_array)))
  
  if (sample=="sc"){
    mycolor <- "red"
  } else if (sample=="bulk") {
    mycolor <- "dodgerblue2"
  }
  
  
  Values <- sapply(window_sizes, FUN = CalculateStatistics, coverage_array = coverage_array)
  rownames(Values) <- c("Gini coefficient","Coefficient of variation","MAD","Autocorrelation")
  colnames(Values) <- window_sizes
  newValues <- as.data.frame(t(Values))
  newValues$windows <- rownames(newValues)
  Statistics <- pivot_longer(data = newValues, cols = c(`Gini coefficient`,`Coefficient of variation`,MAD,Autocorrelation)) %>%
    as.data.frame()
  
  Statistics$name <- factor(as.factor(Statistics$name), levels = c("Gini coefficient","Coefficient of variation","MAD","Autocorrelation"))
  
  Statistics$sample <- rep(sample, nrow(Statistics))
  
  return(Statistics)
  
}


########################
#     SIMULATIONS      #
########################


N=1000000
window_sizes <- c(1,2,3,4,7,15,25,50,100,200,500,1000,2000,3000,5000,10000)
#N=10000
#window_sizes <- c(1,2,3,4,7,15,25,50,100,200,300,400,700)

# CREATE A BULK (LACK OF STRUCTURE)
# Careful!!window sizes must be reasonably smaller than N or the program will fail
coverage_array_bulk <- rpois(n = N, lambda = 20)
bulk_table <- ObtainPlotsStatistics(coverage_array = coverage_array_bulk, window_sizes = window_sizes)


# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS TOGETHER, 500)
amplicon_length  <- 500
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
  lambda_pois <- rpois(n=1, lambda = 20)
  amplicon <- rpois(n = amplicon_length, lambda = lambda_pois)
  previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_sc <- previous_amplicons
sc_table <- ObtainPlotsStatistics(coverage_array = coverage_array_sc, window_sizes = window_sizes)



# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS TOGETHER, 500, higher dispersion in global, lower dispersion within each amplicon)
amplicon_length  <- 500
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
  lambda_pois <- rnbinom(n = 1, size = 10, mu = 20) # mu corresponds to the mean # size allows to slide the distribution towards that value -> hist(rnbinom(n = 200, size = 1, mu = 20))
  #lambda_pois <- rpois(n=1, lambda = 20)
  amplicon <- round(runif(n = amplicon_length, min = lambda_pois - (lambda_pois/10), max = lambda_pois + (lambda_pois/10)))
  #amplicon <- rep(lambda_pois,amplicon_length)
  previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_sc500lessbias <- previous_amplicons
sc500lessbias_table <- ObtainPlotsStatistics(coverage_array = coverage_array_sc500lessbias, window_sizes = window_sizes)




# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS TOGETHER, 2000)
amplicon_length  <- 2000
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
  lambda_pois <- rpois(n=1, lambda = 20)
  amplicon <- rpois(n = amplicon_length, lambda = lambda_pois)
  previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_sc2000 <- previous_amplicons
sc2000_table <- ObtainPlotsStatistics(coverage_array = coverage_array_sc2000, window_sizes = window_sizes)


# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS SEPARATED NON RANDOM)
amplicon_length  <- 500
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
  amplicon_length  <- rpois(lambda = 500, n = 1)
  lambda_pois <- rpois(n=1, lambda = 20)
  amplicon <- rpois(n = amplicon_length, lambda = lambda_pois)
  space_length  <- 100 
  amplicon <- c(amplicon, rep(0,space_length))
  previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_scseparated100 <- previous_amplicons[1:1000000]
scseparated100_table <- ObtainPlotsStatistics(coverage_array = coverage_array_scseparated100, window_sizes = window_sizes) 


# CREATE STRUCTURED COVERAGE PROFILE (AMPLICONS SEPARATED RANDOMLY)
amplicon_length  <- 500
number_amplicons <- round(N / amplicon_length)
previous_amplicons <- c()
for (i in 1:number_amplicons){
  amplicon_length  <- rpois(lambda = 500, n = 1)
  lambda_pois <- rpois(n=1, lambda = 20)
  amplicon <- rpois(n = amplicon_length, lambda = lambda_pois)
  space_length  <- runif(1, min=0, max=100) # random value between 0 and 1000
  amplicon <- c(amplicon, rep(0,space_length))
  previous_amplicons <- c(amplicon, previous_amplicons)
}
coverage_array_scseparated <- previous_amplicons[1:1000000]
scseparated_table <- ObtainPlotsStatistics(coverage_array = coverage_array_scseparated, window_sizes = window_sizes) 

# COMBINE RESULTS

Statistics <- rbind.data.frame(bulk_table, sc_table, sc500lessbias_table, sc2000_table, scseparated100_table, scseparated_table) %>%
  dplyr::mutate(sample = fct_recode(sample, "Bulk" = "bulk","Single cell 1"="sc", "Single cell 2" = "sc500lessbias", "Single cell 3"="sc2000", "Single cell 4" = "scseparated100", "Single cell 5"="scseparated"))

coverage_profiles <- cbind(coverage_array_bulk, coverage_array_sc, coverage_array_sc500lessbias, coverage_array_sc2000, coverage_array_scseparated100, coverage_array_scseparated) %>%
  as.data.frame() %>%
  add_column(y = seq(1:length(coverage_array_bulk))) %>%
  reshape2::melt(value.name = "Coverage", id.vars=c("y")) %>%
  dplyr::rename(sample=variable) %>%
  dplyr::mutate(sample = fct_recode(sample, "Bulk" = "coverage_array_bulk","Single cell 1"="coverage_array_sc","Single cell 2"="coverage_array_sc500lessbias","Single cell 3"="coverage_array_sc2000","Single cell 4" = "coverage_array_scseparated100","Single cell 5"="coverage_array_scseparated"))

# SAVE THE RESULTS TO AVOI RERUNNING

#saveRDS(object = Statistics, file = paste(in_dir,"StatisticsCoverageProfiles.rds",sep=""))
#saveRDS(object = coverage_profiles, file = paste(in_dir,"CoverageProfiles.rds",sep=""))

########################
#        PLOT          #
########################

coverage_profiles <- readRDS(file = paste(in_dir,"CoverageProfiles.rds",sep=""))
Statistics <- readRDS(file = paste(in_dir,"StatisticsCoverageProfiles.rds",sep=""))

Statistics$sample <- factor(as.factor(Statistics$sample), levels = c("Bulk", "Single cell 1", "Single cell 2", "Single cell 3", "Single cell 4", "Single cell 5"))

window_sizes <- c(1,2,3,4,7,15,25,50,100,200,500,1000,2000,3000,5000,10000)

StatisticsPlot <- Statistics %>%
  dplyr::filter(as.numeric(windows)<=10000) %>%
  ggplot(aes(x=as.numeric(windows), y=as.numeric(value), group=sample, color=sample)) +
  geom_line(alpha=0.5) +
  theme_linedraw() +
  geom_point(size=1, alpha=0.5) +
  scale_color_brewer(palette = "Dark2") +
  #scale_color_manual(values=c("dodgerblue2","orange","pink","red","darkred")) +
  scale_x_continuous(trans = 'log10', breaks=as.numeric(unique(window_sizes)), labels =paste( f2si(as.numeric(window_sizes)),"bp",sep="")) +
  facet_wrap(. ~ name, scales = "free", nrow = 1) +
  labs(x="Window size or \u0394 ", y="", col="SIMULATED") +
  theme(legend.position = "bottom", axis.text.x = element_text(angle = 90, hjust = 1,vjust = 0.5, size = 6))


coverage_profiles$sample <- factor(as.factor(coverage_profiles$sample), levels = c("Bulk", "Single cell 1", "Single cell 2", "Single cell 3", "Single cell 4", "Single cell 5"))

CoveragePlot <- coverage_profiles %>%
  ggplot(aes(y=Coverage, x=y, col=sample)) +
  geom_point(size=0.3, alpha=0.5) +
  xlim(0,5000) +
  ylim(0,60) +
  geom_vline(data=filter(coverage_profiles, sample=="Single cell 1"), aes(xintercept = c(500)), col="gray", linetype=2,size=1.2) +
  geom_vline(data=filter(coverage_profiles, sample=="Single cell 2"), aes(xintercept = c(500)), col="gray", linetype=2,size=1.2) +
  geom_vline(data=filter(coverage_profiles, sample=="Single cell 3"), aes(xintercept = c(2000)), col="gray", linetype=2,size=1.2) +
  theme_linedraw() +
  scale_color_brewer(palette = "Dark2") +
  #scale_color_manual(values = c("dodgerblue2","orange","pink","red","darkred")) +
  facet_grid(sample ~ ., scales = "free_y") +
  labs(x="Positions", y="Coverage") +
  theme(legend.position = "none")

coverage_profiles %>% group_by(sample) %>% summarize(var(Coverage))
coverage_profiles %>% group_by(sample) %>% summarize(mean(Coverage))


FinalPlot <- ggarrange(plotlist = list(CoveragePlot, StatisticsPlot), ncol = 1, labels = c('a','b'), heights = c(1.5, 1))
ggsave(plot = FinalPlot, filename = paste("/Users/tama/Downloads/SimulationsCoverage.png", sep=""), width = 10, height = 12)


