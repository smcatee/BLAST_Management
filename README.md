These scripts help manage FASTA files, BLAST output, and highest scored hits selection from the original FASTA files for multi-seq alignment.
Each script was written as needed during our workflow.

A general outline of our workflow is as follows:

-A BLAST database and a folder of query FASTA files are prepared for BlastAllInFolder.sh
-Set the BLAST type, e-value cutoff, and output folder path
-Run BlastAllInFolder.sh, the output is a tab separated .txt file
-Manual selection of best hits (Excel or R)
-The manually selected best hits .csv files are prepared
-GetFastaSegments.pl takes a folder of .csv files with best hit 'targets' and the folder of FASTA query files
-Set output folder path and run GetFastaSegments.pl
-The output is now ready for MSA