#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import math

if sys.version_info[0] < 3:
    raise "Please, consider upgrading your version to 3.x.x in order to run this script"

if len(sys.argv) < 2:
    sys.exit('Please, provide a sample name as argument')

sample=sys.argv[1]
workdir=sys.argv[2]
depth=sys.argv[3]
alpha=sys.argv[4]
chrom=sys.argv[5]
suffix=".txt"
file_name= workdir + "CorrMag." + sample + ".chr"+ chrom +"." + depth + "." + alpha + suffix
print("Loading data frame ",file_name,"...\n") 

n=0
mult_sum=0
first_sum=0
num=0
with open(file_name, mode='r') as f:
    for line in f: 
        line_cols=re.split(r'\t+', line)
        if (line_cols[0] != 'N' and line_cols[1] != 'N' and len(line_cols)==4): # Pass positions with masked reference
            first_sum+=int(line_cols[2])
            mult=(int(line_cols[2]) * int(line_cols[3]))
            mult_sum+=mult
            n+=1
            num+=1
        elif (line_cols[0] != 'N' and len(line_cols)==2):
            first_sum+=int(line_cols[1])
            num+=1
f.close()
a=mult_sum/n
b=math.pow(first_sum/num,2)
autocorrelation=(a-b)/b
print(autocorrelation)
out = open(workdir + "Autocorrelation." + sample + ".chr" + chrom +"."+ depth + "." + alpha + ".txt","w")
out.write(str(sample)+"\t"+str(alpha)+"\t"+str(autocorrelation)+"\n")
out.close()
