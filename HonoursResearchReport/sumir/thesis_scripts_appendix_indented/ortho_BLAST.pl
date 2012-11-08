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
  parseBlast(); # call on my parseBlast sub-routine above to parse the BLAST results
}

sub parseBlast(){
  $count = 0;   # intialiase counter to 0
  open (BLAST, "$outdir/$file.blast"); # open the direcitory containing BLAST results
  while (<BLAST>){
    s/\be\-/1e\-/g;
    @array =split; # place my BLAST output results into an array
    if ($_ =~ /^Query\= /) {
      $query = $array[1]; # palce the accession of my query gene into an array
    }
    elsif ($_ =~ /^>(.+)/) { #if my BALST hit has more then 1 sequence
      ++$count;              #then continue counting
      if ($count == 1){
	$hit1 = $1;
      }
    }
    elsif ($_ =~ /Expect = (\S+)/){
      if ($count == 1){
	$E1 = $1;
      }
    }

    if ($_ =~ /Identities \= \d+\/\d+ \((\d+)\%.*\((\d+)\%\)/) {
      if ($count == 1){
	$percent1 = $1;
      }
    }
    elsif ($_ =~ /No hits/)  {
      $percent1 = 0;
    }
  }
  close BLAST;
  # print "$query $hit1 $E1 $percent1\n";
  # parse my BLAST results for and expectation score greter then or equal to 1e10
  # and greater then or equal to 50% coverage and similiarity
  # also create paired accession file clusters for recpirocal BLASTs
  if ($E1 < 1E-10 && $percent1 >= 50){
    print CLUSTERS "$query $hit1\n";
  }else{
    system "rm -fr $outdir/$file.blast";
  }
}

