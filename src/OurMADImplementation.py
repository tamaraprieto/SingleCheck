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
print("Mean cell coverage per window:", mean_cov)

sumnorm=0
n=0
vector_diff=[]
value_sum=0
with open(input_name, mode='r') as f:
    for line in f:
        cols=re.split(r'\t+', line)
        fourth=int(cols[3])
        norm=fourth/mean_cov
        if ( n==0 ):
            prev=norm
        else:
            value=prev-norm
            vector_diff.append(value)
            prev=norm
        n+=1
f.close()

vector_diff_median=statistics.median(vector_diff)
array=numpy.array(vector_diff)
abs_vector=abs(array-vector_diff_median)
myMAD=statistics.median(abs_vector)
print("MAD:",myMAD)
out.write(str(myMAD)+"\n")
