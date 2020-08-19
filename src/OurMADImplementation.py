#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import numpy
import statistics

if sys.version_info[0] < 3:
    raise Exception ("Please, consider upgrading your version to 3.x.x in order to run this script")

if len(sys.argv) < 2:
    sys.exit('Please, provide a sample name as argument')


sample=sys.argv[1]
workdir=sys.argv[2]
depth=sys.argv[3]
size=sys.argv[4]

suffix="bp.bed"
input_name= workdir + sample + "." + depth + "X." + size + suffix
print("Loading data frame ",input_name,"...\n") 
out = open(workdir+"OurMAD."+sample+"."+depth+"."+size+".txt","w")

# 1. Calculatw mean read count across bins
sumcov=0
n=0
with open(input_name, mode='r') as f:
    for line in f: 
        cols=re.split(r'\t+', line)
        fourth=int(cols[3])
        sumcov+=fourth
        n+=1
f.close()
mean_cov=sumcov/n
print("Mean read count across bins:", mean_cov)

# 2, Normalize read counts in each bin by the mean coverage
# 3. Calculate pairwise differences in read counts between neighboring bins
sumnorm=0
n=0
vector_diff=[]
value_sum=0
with open(input_name, mode='r') as f:
    for line in f:
        cols=re.split(r'\t+', line)
        fourth=int(cols[3])
        # 2.
        norm=fourth/mean_cov
        if ( n==0 ):
            prev=norm
        # 3. 
        else:
            value=prev-norm
            vector_diff.append(value)
            prev=norm
        n+=1
f.close()

# Calculate MAD. median(abs(x-median(x)))
vector_diff_median=statistics.median(vector_diff)
array=numpy.array(vector_diff)
abs_vector=abs(array-vector_diff_median)
myMAD=statistics.median(abs_vector)
print("MAD:",myMAD)
out.write(str(myMAD)+"\n")
