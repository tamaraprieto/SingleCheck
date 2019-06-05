#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import tabix
import linecache
import math

if sys.version_info[0] < 3:
    raise "Please, consider upgrading your version to 3.x.x in order to run this script"

if len(sys.argv) < 2:
    sys.exit('Please, provide a sample name as argument')

sample=sys.argv[1]
workdir=sys.argv[2]
depth=sys.argv[3]
suffix=".mpileup"
mpileup_name= workdir + sample + "." + depth + suffix
print("Loading data frame ",mpileup_name,"...\n") 

n=0
m=0
alpha=1000
mult_sum=0
first_sum=0
with open(mpileup_name, mode='r') as f:
    for first in f: 
        first_cols=re.split(r'\t+', first)
        m+=1 # I should keep moving in the same way even if I do not count positions without a defined base
        if (first_cols[2] != 'N'): # Pass positions with masked reference
            n+=1
            second=linecache.getline(mpileup_name, m+alpha)
            sum=int(first_cols[3])
            first_sum+=sum
            if second:
                second_cols=re.split(r'\t+', second)
                mult=(int(first_cols[3]) * int(second_cols[3]))
                mult_sum+=mult
f.close()
a=mult_sum/(n-alpha)
b=math.pow(first_sum/n,2)
autocorrelation=(a-b)/b
print(autocorrelation)
out = open(workdir+"Autocorrelation."+sample+"."+depth+"."+alpha+".txt","w")
out.write(str(autocorrelation)+"\n")
out.close()
