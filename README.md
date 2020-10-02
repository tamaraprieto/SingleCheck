
#### SingleCheck is a program for assessing coverage dispersion of single cell DNA-seq libraries 

<!-- background / introduction -->

<!-- ## Installation -->

### Dependencies

* [BWA-MEM](https://github.com/lh3/bwa)
* [PICARD](https://broadinstitute.github.io/picard/)
* [mosdepth](https://github.com/brentp/mosdepth)
* [bedtools](https://bedtools.readthedocs.io/en/latest/)
* [samtools](http://www.htslib.org/)
* R packages for the main program:
	* tidyr
	* dplyr
	* matrixStats
* R packages for the shiny app (optional):
  * shiny
  * shinydashboard
  * shinycssloaders
  * DT
  * data.table
  * ggplot2
  * plotly


## Usage

```
SingleCheck [options] <in.bam|in.fastq.gz> <in2.fastq.gz>

options:
  -h  show this help text
  -w <int> set the window size for gini coefficient, coefficient of variation and MAD efault: 10000000)
  -i <int> set increment/Delta for autocorrelation (default: 1000)
  -t <int> number of threads
  -f <int> flag of the reads to filter out
  -q <int>  mapping quality of the reads to analyze
  -r <ref.fa> reference genome
  -X include chromosome X in the analysis (only for human samples)
  -N do not perform downsampling. Extract statistics from original file
  -d downsampling sequencing depth. Ignore if -N (default: 0.1)
  -s <ConstantMemory|HighAccuracy|Chained> downsampling strategy method.
     Read Picard DownsampleSam documentation for details:
     https://broadinstitute.github.io/picard/command-line-overview.html#DownsampleSam
     Ignore if -N (default: ConstantMemory)
  -c <STRING> string containing all the names of the chromosomes you want to analyze parated by vertical bars enclosed in single or double quotation marks. Ignore if your ganism of study is human. Sintax of regular expression allowed
    	examples:
    		'2|3|4|X'
    		'[1-9]'
    		'chr[1-9|Z]'
    		'NC87126|NC78623'
    		'NW_[0-9]*'
  -m <STRING> mitochondrial contig name if different from MT or chrM. 
     Quotes are not required in this case
```

Example
```bash
SingleCheck test/R1.T15.bam
```

##  Output and interpretation

The program generates a text file with the following columns:

* Name of the sample: single cell or unamplified control
* Sequenced bases: original number of bases present in the input BAM file
* Analysis depth
* Window size
* Delta
* % of unmapped reads	
* % of reads mapped to the mitochondria	
* Breadth: % of genome covered by &#8805;1 read	
* Autocorrelation	
* Coefficient of variation	
* Gini coefficient	
* MAD	
* Potential contaminants (Metaphyler genus file information condensed)


For comparing results from the different single cells simultaneously, we created a shiny app that it is available at xxxxxxxxxxxx

In order to create the input for the app you must run the following line:

```bash
CreateInputApp.sh <Samples.txt>
```

Example of Samples.txt
```
R1.T15
R20.S5
R9.S1
```

Then, you can load the output on the Input tab in the menu panel of the app. 

## Current issues

## FAQ

1. Can I use SingleCheck for performing quality control of single-cell RNA-seq data?

We have not tested the program for this aim so we do not provide support for this. 

2. Should I remove duplicates from my data?

We think is better to keep the duplicates for quality control the single cells.


<!-- ## How to cite -->
