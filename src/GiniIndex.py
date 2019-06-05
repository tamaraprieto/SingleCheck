#!/usr/bin/env python

# Written by Tamara Prieto
# May 2019 at Uvigo

import re
import sys
import math

if sys.version_info[0] < 3:
    raise Exception ("Please, consider upgrading your version to 3.x.x in order to run this script")

if len(sys.argv) < 2:
    sys.exit('Please, provide a sample name as argument')


sample=sys.argv[1]
workdir=sys.argv[2]
depth=sys.argv[3]

suffix=".counts.txt"
input_name= workdir + sample + "." + depth + suffix
print("Loading data frame ",input_name,"...\n") 
out = open(workdir+"Gini."+sample+"."+depth+".txt","w")

sum_colb=0
numerator_mean=0
with open(input_name, mode='r') as f:
    for line in f: 
        cols=re.split(r'\t+', line)
        a=int(cols[0])
        b=int(cols[1])
        numerator_mean+=a*b
        sum_colb+=b
f.close()
mean=numerator_mean/sum_colb

n=0
sumatory=0
with open(input_name, mode='r') as f:
    for line in f:
        cols=re.split(r'\t+', line)
        n+=1
        a=int(cols[0])
        value=n*(a-mean)
        sumatory+=value
f.close()

mygini=(2/((sum_colb**2)*mean)) * sumatory
print(mygini)
out.write(str(mygini)+"\n")
