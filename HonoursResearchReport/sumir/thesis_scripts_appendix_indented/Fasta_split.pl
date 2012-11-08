#!/usr/bin/perl -w
# Alan Christoffels- 14.01.99
# fasta_split.pl - script to read in a fasta formated file of sequences and
# print out each sequence in a seperate file where the file names are
# sequencename.fasta

$/="\n>";# set my deliminator to be a new line with a > fatsa header
$file = $ARGV[0]; # specifiy the input file as the first file o the command line
$dir = $ARGV[1]; # specify the ouput directory to write out the sequences
$i= 0; # initialise my counter to 0
system "mkdir $dir"; # create my puput direcotory specified on the command line
open (FILE, "$file"); #open the input file
while (<FILE>) {   # while in the input file
  $i++;          # keep reading all the sequences
  chop $_;       # remove stop codon * from end of sequence

  if ($i > 1) {   # as soon as my sequence count reaches 1, add fasta headers
    $_ = ">".$_;
  }

  if ($_=~/^>/) {  # pattern match for fasta headers
    $_ =~/^>(\S+)\s+/; # place gene accession into $_varialble
    $name = $1; # name my sequence using the accesion ID
    $name =~ s/\|/_/g; # substitute "pipes" for underscores
    open (F, ">$dir/$name.fasta");#open my command line specified output file
    print F "$_\n"; # print my individual sequence file into a file named
    close(F); #after its accession ID with a .fasta file extension
  }
}
close(FILE);
