#!/bin/bash

##Author: Sean McAtee
##Version: 6/3/2019

##About: This will look through all files in a folder and within each file append part of the file name after each '>'


#folder path without the last "/"
inputFolder="/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/Trinity"

for file in ${inputFolder}/*.fasta; do

        PYCCode=${file##*_}
        PYCCode=${PYCCode%%.*}

        perl -i -p -e "s/TRINITY/TRINITY_${PYCCode}/g" ${file}

done