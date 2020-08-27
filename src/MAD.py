#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import math
import numpy
import statistics

if sys.version_info[0] < 3:
    raise "Please, consider upgrading your version to 3.x.x in order to run this script"

if len(sys.argv) < 2:
    sys.exit('Please, provide a sample name as argument')

sample=sys.argv[1]
workdir=sys.argv[2]
depth=sys.argv[3]
size=sys.argv[4]
suffix=".txt"
# ${WORKDIR}/ForMAD.${SAMPLE}.${DEPTH}.${size}.txt
file_name= workdir + "ForMAD." + sample + "." + depth + "." + size + suffix
print("Loading data frame ",file_name,"...\n") 

# 1. Calculate mean read count across bins
print ("Calculating mean read count across bins")
first_sum=0
num=0
with open(file_name, mode='r') as f:
    for line in f:
        line_cols=re.split(r'\t+', line)
        first_sum+=float(line_cols[0])
        num+=1
f.close()
mean_window_depth = first_sum / num
print ("Mean depth across bins: ",mean_window_depth)

# 2, Normalize read counts in each bin by the mean coverage
# 3. Calculate pairwise differences in read counts between neighboring bins
print ("Normalizing read counts in each bin by the mean coverage and calculating pairwise differences in read counts between neighboring bins")
vector_diff=[]
with open(file_name, mode='r') as f:
    for line in f: 
        line_cols=re.split(r'\t+', line)
        if (len(line_cols)==2): # Pass positions with masked reference
            actual = float(line_cols[0])/mean_window_depth
            forward = float(line_cols[1])/mean_window_depth
            vector_diff.append(actual - forward)
f.close()

# Calculate MAD: median(abs(x-median(x)))
print ("Calculating MAD")
vector_diff_median=statistics.median(vector_diff)
array=numpy.array(vector_diff)
abs_vector=abs(array-vector_diff_median)
myMAD=statistics.median(abs_vector)
print("MAD:",myMAD)
out = open(workdir + "MAD." + sample + "." + depth + "." + size + ".txt","w")
out.write(str(myMAD)+"\n")
