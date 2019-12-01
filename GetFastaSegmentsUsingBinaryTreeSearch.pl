#!/usr/bin/env perl
use strict;
use warnings;

##Author: Sean McAtee
##Version: 8/14/2019

##About:

#~~~~~~~~~~~~~~~~Enter your appropriate paths for input folder with .csv files and output folder~~~~~~~~~~~~~~~~~~~
        #   I did not build in much error checking,
        #   so make sure to input only the folder containing 
        #   .csv files with subject_acc.ver, Species, s_start, s_end
        #   in columns 2, 3, 10, 11 respectively.
my $inputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/tBLASTn_Output/MoreCleanedOutput/';
my $outputFolderPath = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/tBLASTn_Output/BLASTFastaSegmentsInclComplements/';

#fasta db file as .txt
my $fastaFile = '/Users/smcatee/Desktop/TF/PYC/Data/tBLASTn_inputs_outputs/Trinity_Concat/All.Trinity.txt';

#path to read or save variables.  If none listed then './BinarySearchVariables/' will be used
my $variablesFilePath = '';

#~~~~~~~~~~~~~~~~The following code doesn't need to be modified~~~~~~~~~~~~~~~~~~~





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
shift @fastaArray;
my @fastaTitles;
foreach ( @fastaArray ) {
    my $title = substr $_, 0, index($_, ' ');
    push @fastaTitles, $title if $title ne "";
}



#check if variables (Title, TitleSorted, TitleOrder) are already saved locally.
    #else create and store variables.
$variablesFilePath = './BinarySearchVariables/' if ($variablesFilePath eq '');
mkdir $variablesFilePath unless -d $variablesFilePath;

if ( -e $variablesFilePath.'Titles.csv' ) {
    open ( my $csvTitles, $variablesFilePath.'Titles.csv' )
        or die "Could not open Titles.csv: $!"
    
}



#binary search on @fastaTitles for $fastaTitlesSorted[$i]
#find the index in @fastaTitles that the current $fastaTitlesSorted[$i] corresponds to
#save that index as the $i element in @fastaTitlesOrder


print "Preparing sorted values and indexes for binary search...\n";
my @fastaTitlesSorted = sort { $a cmp $b } @fastaTitles;
my @fastaTitlesOrder = map { [] } 0 .. $#fastaTitles;


for my $i ( 0 .. $#fastaTitles ) {

    my $upperBiSearchIndex = $#fastaTitles;
    my $lowerBiSearchIndex = 0;
    my $biSearchIndex = 0;

    while ( $upperBiSearchIndex != $lowerBiSearchIndex ) {
        #to prevent index getting stuck
        if ( $biSearchIndex != $lowerBiSearchIndex + int( ( $upperBiSearchIndex - $lowerBiSearchIndex )/2 ) ) {
            $biSearchIndex = $lowerBiSearchIndex + int( ( $upperBiSearchIndex - $lowerBiSearchIndex )/2 );
        } else {
            $biSearchIndex = $biSearchIndex + 1;
        }

        if ( $fastaTitles[$i] eq $fastaTitlesSorted[$biSearchIndex] ) {
            last;
        } elsif ( $fastaTitles[$i] lt $fastaTitlesSorted[$biSearchIndex] ) {
            $upperBiSearchIndex = $biSearchIndex;
        } else {
            $lowerBiSearchIndex = $biSearchIndex;
        }
    }


    $fastaTitlesOrder[$biSearchIndex] = $i;
    print "$i of $#fastaTitles";
    print "\n";
}

#save @fastaTitlesOrder and @fastaTitlesSorted in csv format for easy parsing and passing to R
print "Saving variables in $variablesFilePath";
open my $outTitles, '>', $variablesFilePath.'Titles.csv' or die "Could not write variables to file: $!";
open my $outTitlesSorted, '>', $variablesFilePath.'TitlesSorted.csv' or die "Could not write variables to file: $!";
open my $outTitlesOrder, '>', $variablesFilePath.'TitlesOrder.csv' or die "Could not write variables to file: $!";

print $outTitles ( join ',', @fastaTitles );
print $outTitlesSorted ( join ',', @fastaTitlesSorted );
print $outTitlesOrder ( join ',', @fastaTitlesOrder );

close $outTitles;
close $outTitlesSorted;
close $outTitlesOrder;



# All return true
# print $fastaTitlesSorted[2] eq $fastaTitles[19];
# print "\n";
# print $fastaTitlesSorted[3] eq $fastaTitles[74];
# print "\n";
# print $fastaTitlesSorted[4] eq $fastaTitles[42];
# print "\n\n";


#binary search against *Sorted and get the index of the hit
    #use that index on *Order to get the index of @fastaArray (which is same as @fastaTitleNumbers and @fastaTitles)


# #for each BLAST results table in the inputFolder

# opendir( my $dh, $inputFolderPath )
#     or die "Could not open $inputFolderPath: $!";

# my @fileList = readdir $dh;

# foreach( @fileList ) {
#     my $inputFileName = $_;
#     print "Loading file: $inputFileName\n";

#     if ( $inputFileName =~ /csv$/ ) {
#         my $BLASTFile = "$inputFolderPath$_";
#         my $outputFileName = $inputFileName;
#         $outputFileName =~ s/csv/txt/g;

#     open (my $BLASTHits, $BLASTFile)
#         or die "Could not open $BLASTFile: $!";


#     print "Finding segments in db and appending into output file\n";
#     #work through each line of $BLASTHits
#     while( my $BLASTHitsLine = <$BLASTHits> ) {
#         my $subject_acc_ver = (split /,/, $BLASTHitsLine)[1];
#         my $Species = (split /,/, $BLASTHitsLine)[2];
#         my $s_start = (split /,/, $BLASTHitsLine)[9];
#         my $s_end = (split /,/, $BLASTHitsLine)[10];
        
#         #skip to next row if any variables are blank
#         next if $subject_acc_ver eq "";
#         next if $Species eq "";
#         next if $s_start eq "";
#         next if $s_end eq "";

#         for my $i (0 .. $#fastaArray )  {
#             if (index( $fastaTitles[$i] , $subject_acc_ver) != -1 ) {

#             #get substring of only nucleotides
#                 my $nucleotides = (split /[(len)\[\]]/, $fastaArray[$i])[-1];
#                 $nucleotides =~ s/\n//g;


#                 #if nucleotide code is not reverse direction or if is reverse
#                 if ( $s_start < $s_end ) {
#                     my $outputFasta = (substr $nucleotides, ($s_start - 1), ($s_end - $s_start));
#                     $outputFasta = '>'.$Species.' '.$subject_acc_ver.' len='.($s_end - $s_start)."\n".$outputFasta;
#                     open (my $fh, '>>', $outputFolderPath.$outputFileName) or die "Could not print output!";
#                     say $fh $outputFasta;
#                     close $fh;

#                 } else {
#                     my $outputFasta = (substr $nucleotides, ($s_end - 1), ($s_start - $s_end));
#                     #make compliment
#                     $outputFasta =~ tr/ATGC/TACG/;
#                     #reverse
#                     $outputFasta = scalar reverse $outputFasta;
#                     $outputFasta = '>'.$Species.' '.$subject_acc_ver.'complement len='.($s_start - $s_end)."\n".$outputFasta;
#                     open (my $fh, '>>', $outputFolderPath.$outputFileName) or die "Could not print output!";
#                     say $fh $outputFasta;
#                     close $fh;
#                 }
#                 last;
#             }
#         }
#     }

#     close $BLASTFile;
#     close $BLASTHits;
#     }
# }
# closedir $dh;
# close $fastaFile;
# close $fasta;

