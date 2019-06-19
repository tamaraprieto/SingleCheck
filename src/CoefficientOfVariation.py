#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import numpy
import math

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
out = open(workdir+"CV."+sample+"."+depth+"."+size+".txt","w")

sumcov=0
n=0
with open(input_name, mode='r') as f:
    for line in f: 
        cols=re.split(r'\t+', line)
        fourth=int(cols[3])/int(size)
        sumcov+=fourth
        n+=1
f.close()
mean_cov=sumcov/n
print("Mean cell coverage per window:", mean_cov)

n=0
sum_rest=0
with open(input_name, mode='r') as f:
    for line in f:
        cols=re.split(r'\t+', line)
        fourth=(int(cols[3])/int(size))
        rest=(fourth-mean_cov)**2
        sum_rest+=rest
        n+=1
f.close()

print("Sum: ", sum_rest)
sd_cov=math.sqrt(sum_rest/(n-1))
cv=sd_cov/mean_cov
print("CV:",cv)
out.write(str(cv)+"\n")
