#!/usr/bin/perl
use strict;
use warnings;

##Author: Sean McAtee
##Version: 8/7/2019

##About:

#~~~~~~~~~~~~~~~~Enter your appropriate paths for input folder with .csv files and output folder~~~~~~~~~~~~~~~~~~~
        #   I did not build in much error checking,
        #   so make sure to input only the folder containing 
        #   .csv files with subject_acc.ver, Species, s_start, s_end
        #   in columns 2, 3, 10, 11 respectively.
my $inputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/Cleaned_MultiAlignment_input_output/Ribo_csv_seqs/';
my $outputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/Cleaned_MultiAlignment_input_output/Ribo_MSA_seqs';

#fasta db file as .txt
my $fastaFile = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/Trinity_Concat/All.Trinity.txt';


#~~~~~~~~~~~~~~~~The following code doesn't need to be modified~~~~~~~~~~~~~~~~~~~

#parse csv file into arrays
    #Saves cols: subject_acc.ver, Species, s_start, s_end.

print "Loading fasta db. This may take a minute or so...\n";
my $fasta;
open (my $openedFasta, $fastaFile)
    or die "Could not open $fastaFile: $!";
{
    local $/;
    $fasta = <$openedFasta>;
}
close($openedFasta);

my @fastaArray = (split />/, $fasta);
my @fastaTitles;
foreach ( @fastaArray ) {
    push @fastaTitles, substr $_, 0, index($_, ' ');
}



#for each BLAST results table in the inputFolder

opendir( my $dh, $inputFolderPath )
    or die "Could not open $inputFolderPath: $!";

my @fileList = readdir $dh;

foreach( @fileList ) {
    my $inputFileName = $_;
    print "Loading file: $inputFileName\n";

    if ( $inputFileName =~ /csv$/ ) {
        my $BLASTFile = "$inputFolderPath$_";
        my $outputFileName = $inputFileName;
        $outputFileName =~ s/csv/txt/g;

    open (my $BLASTHits, $BLASTFile)
        or die "Could not open $BLASTFile: $!";


    #make output directory
    mkdir $outputFolderPath unless -d $outputFolderPath;


    print "Finding segments in db and appending into output file\n";
    #work through each line of $BLASTHits
    while( my $BLASTHitsLine = <$BLASTHits> ) {
        my $subject_acc_ver = (split /,/, $BLASTHitsLine)[1];
        my $Species = (split /,/, $BLASTHitsLine)[2];
        my $s_start = (split /,/, $BLASTHitsLine)[9];
        my $s_end = (split /,/, $BLASTHitsLine)[10];
        
        #skip to next row if any variables are blank
        next if $subject_acc_ver eq "";
        next if $Species eq "";
        next if $s_start eq "";
        next if $s_end eq "";

        for my $i (0 .. $#fastaArray )  {
            if (index( $fastaTitles[$i] , $subject_acc_ver) != -1 ) {

            #get substring of only nucleotides
                my $nucleotides = (split /[(len)\[\]]/, $fastaArray[$i])[-1];
                $nucleotides =~ s/\n//g;


                #if nucleotide code is not reverse direction or if is reverse
                if ( $s_start < $s_end ) {
                    my $outputFasta = (substr $nucleotides, ($s_start - 1), ($s_end - $s_start));
                    $outputFasta = '>'.$Species.' '.$subject_acc_ver.' len='.($s_end - $s_start)."\n".$outputFasta;
                    open (my $fh, '>>', $outputFolderPath.$outputFileName) or die "Could not print output!";
                    say $fh $outputFasta;
                    close $fh;

                } else {
                    my $outputFasta = (substr $nucleotides, ($s_end - 1), ($s_start - $s_end));
                    #make compliment
                    $outputFasta =~ tr/ATGC/TACG/;
                    #reverse
                    $outputFasta = scalar reverse $outputFasta;
                    $outputFasta = '>'.$Species.' '.$subject_acc_ver.' complement len='.($s_start - $s_end)."\n".$outputFasta;
                    open (my $fh, '>>', $outputFolderPath.$outputFileName) or die "Could not print output!";
                    say $fh $outputFasta;
                    close $fh;
                }
                last;
            }
        }
    }

    close $BLASTFile;
    close $BLASTHits;
    }
}
closedir $dh;
close $fastaFile;
close $fasta;

