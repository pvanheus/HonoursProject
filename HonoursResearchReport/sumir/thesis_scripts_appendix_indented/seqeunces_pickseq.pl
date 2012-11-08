#! /usr/bin/perl
# subroutine to parse BLAST results
use warnings ;

if ($#ARGV < 2) { #print warningd  on command line if I forget an input file
  print "usage: ortho_BALST.pl [input dir] [database1] [output dir]\n";
  exit;
}

$dir = $ARGV[0];  # intialise my input directory, database and output directory
$dbase1 = $ARGV[1];
$outdir = $ARGV[2];

system "mkdir $outdir"; # unix system command to make my output directory
open (CLUSTERS, ">clusters"); # print paired accessions to file called clusters

opendir(DIR, "$dir"); # open my input direcotiry to read sequence files
@files = readdir(DIR); # read sequence files
foreach $file(@files) { # for each sequence file read, run a BLAST using the
  next unless (-f "$dir/$file");
  # unix system call and BLAST commands below
  system "blastall -p blastp -d ./$dbase1 -i $dir/$file -v 1 -b 1 -F F > $outdir/$file.blast";
}

  }
  close BLAST;

