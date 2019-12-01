#!/bin/bash

## Author: Sean McAtee
## Version: 7/30/2019


##  About:
##      This script will run a blast search on all .fasta files in the folder
##      A new directory will be generated to hold the output files
##      The output will be tab delimited for easy manipulation in R
##      The output will be concatenated with a .txt file that contains column names



## ~~~~~~~~~  Modify this code to fit your file organization  ~~~~~~~~~~~~~



#enter the db path as you would in blast (i.e. exclude file type.)
dbPath='/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/Trinity_Concat/BLASTDB.TRINITY'

#enter the path to the folder holding query files WITHOUT a final '/' after the folder name
filesPath='/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/56_exons_1166_1205'

#enter the type of blast search as you would enter in the command line (e.g. 'blastn', 'blastp', 'blastx', 'tblastn', 'tblastx')
blastSearchType='tblastx'

#enter the e-value cutoff as a number or exponent (e.g. '0.002' OR '2e-3')
eValue='1e-10'

#enter the path where you want the output folder to be created (WITH the final '/' in the path)
outputFolderPath='/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/56_exons_1166_1205/'

## ~~~~~~~~~  The following code should run without any further modifications, but feel free to change things and give feedback  ~~~~~~~~~~~~~



#check that input files are .fasta and exist
echo -e "\nChecking if filesPath contains .fasta files..."

if ls ${filesPath}/*.fasta &>/dev/null
then
    echo -e "SUCCESS: .fasta files found in ${filesPath}\n"
    filesList="${filesPath}/*.fasta"
else
    echo -e "FAIL: filesPath does not include .fasta files\nExiting..."
    if ls ${filesPath}/*.txt &>/dev/null
    then
        echo -e "SUCCESS: .txt files found in ${filesPath}/n"
        filesList="${filesPath}/*.txt"
    else
        echo -e "FAIL: filesPath does not include .txt files\nExiting..."
        exit 0
    fi
fi

#check that input db includes .nhr .nin .nsq (and/or others?)
echo "Checking if dbPath contains .nhr & .nin & .nsq files..."

if ls ${dbPath%/*}/*.nhr &>/dev/null && ls ${dbPath%/*}/*.nin &>/dev/null && ls ${dbPath%/*}/*.nsq &>/dev/null
then
    echo -e "SUCCESS: .nhr & .nin & .nsq files found in ${dbPath%/*}\n"
else
    echo -e "FAIL: dbPath does not include .nhr & .nin & .nsq files\nExiting..."
    exit 0
fi


#generate an output folder for BLAST results
outputFolderName="Output_${blastSearchType}_${dbPath##*/}_${filesPath##*/}"
mkdir -p ${outputFolderPath}${outputFolderName}
echo -e "\nBLAST Output folder generated:\n\"${outputFolderPath}${outputFolderName}\""


#for each .fasta query file generate an output file name
#   then run BLAST
#   then prepend column names to the output
for file in ${filesList}; do

    fileName="${file##*/}"
    filePath="${filesPath}/${fileName}"

    outFileName="/Output_${blastSearchType}_${dbPath##*/}_${fileName%.*}.txt"
    outFilePath="${outputFolderPath}${outputFolderName}${outFileName}"
    

    #run BLAST
    echo -e "\nRunning BLAST search on ${fileName}..."
    #outformat "6" is the tab separated format without comments.  It is best for uploading into R tables.
    #outformat "2" gives nucleotide string matches
    ${blastSearchType} -db ${dbPath} -query ${filePath} -evalue ${eValue} -outfmt 6 -out ${outFilePath}
    echo -e "BLAST search complete."

    #append BLAST output to a string containing column names (i.e. fields)
    echo -e "query_acc.ver\tsubject_acc.ver\tidentity%\talignment_length\tmismatches\tgap_opens\tq._start\tq._end\ts._start\ts._end\tevalue\tbit_score"|cat - ${outFilePath} > /tmp/blastOut && mv /tmp/blastOut ${outFilePath}


    unset fileName
    unset filePath
    unset outFileName
    unset outFilePath
done

echo -e "\nAll BLAST searches complete."

