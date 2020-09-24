# SingleCheck

SingleCheck is a program for performing quality control of single-cell DNA-seq libraries

![](Workflow-SingleCheck.png  =100x)

## Installation

Dependencies:
- [BWA-MEM](https://github.com/lh3/bwa)
- [mosdepth](https://github.com/brentp/mosdepth)
- [bedtools](https://bedtools.readthedocs.io/en/latest/)
- [samtools](http://www.htslib.org/)
- R packages: 
	tidyr
	dplyr
	matrixStats 

## Usage

```bash
SingleCheck R1.T15.bam 
```

## Output file


##  Visualization

The program generates a text file with with the following columns:


This output can be inspected using a shiny app that it is available at 

```bash
CreateInputApp.sh <Samples.txt>
```


## How to cite
