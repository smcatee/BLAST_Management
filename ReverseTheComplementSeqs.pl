#!/usr/bin/env perl
use strict;
use warnings;

##Author: Sean McAtee
##Version: 8/14/2019

##About: Finds fasta sequences with the keyword 'complement' and reverses those sequences.
##          Takes multiple files in a specified folder.  Only handles .txt files.  To modify change lines 27 and 30.

#~~~~~~~~~~~~~~~~~~Specify the path to input folder and output folder (output folder does not have to already exist)~~~~~~~~~~~~~~~~~~
my $inputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/tBLASTn_Output/MSA_Input_w_Refseq/';
my $outputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/tBLASTn_Output/MSA_Input_w_Refseq_output/';
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



mkdir $outputFolderPath unless -d $outputFolderPath;

#for each file in folder
opendir( my $dh, $inputFolderPath )
    or die "Could not open $inputFolderPath: $!";

my @fileList = readdir $dh;


foreach( @fileList ) {
    my $inputFileName = $_;

    if ( $inputFileName =~ /txt$/ ) {
        my $BLASTFile = "$inputFolderPath$_";
        my $outputFileName = $inputFileName;
        $outputFileName =~ s/.txt/_output.txt/g;
        my $BLASTFileOut = $outputFolderPath.$outputFileName;

        #prepare input file
        open (my $BLASTIn, $BLASTFile)
            or die "Could not open $BLASTFile: $!";

        #prepare output file
        open my $BLASTOut, '>', "$BLASTFileOut" or die "Could not write to out file: $!";


        #separate fasta if title contians 'complement'
        my $reverseNextLine = 0;
        while ( <$BLASTIn> ) {
            if ( $reverseNextLine == 1 ) {
                $reverseNextLine = 0;
                
                #remove \n char from before reversing, then add one to end after.
                my $revSeq = scalar reverse $_;
                $revSeq =~ s/\R//g;
                $revSeq = "$revSeq\n";

                print $BLASTOut $revSeq;
            } else {
                print $BLASTOut $_;
            }
            if ( $_ =~ /\A>/) {
                if ( $_ =~ /complement/ ) {
                    $reverseNextLine = 1;
                }
            }
        }
        close $BLASTIn;
        close $BLASTOut;
    } else {
        print "$inputFileName is not a txt file."
    }

}


