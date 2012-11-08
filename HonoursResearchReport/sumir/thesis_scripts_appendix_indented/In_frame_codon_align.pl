#!/usr/bin/perl -w
use Cwd;

$maindir = getcwd();
$dir = $ARGV[0];
# open my working directory with all the orthlogous sequences identified by
# reciporcal BLAST and pattern match for direcotires called cluster_
opendir(DIR, "$maindir/$dir") or die "can't opendir";
while (defined($nextdir = readdir(DIR))) {
  if ($nextdir =~ /cluster_.+/)
    {
      print $nextdir;
      in_frame_codon_align("$maindir/$dir/$nextdir");  
    }
}

closedir(DIR);

exit;
#sub-routine to generate ClustalW alignemnts and in-frame codon alignments
# and convert inframe codon aligned sequences into Phylip format
sub in_frame_codon_align{
  my ($nextdir) = $_[0];

  print "**************** $nextdir\n";
  @dir_array = split(/\//, $nextdir);
  $name = $dir_array[$#dir_array];
  
  #Run ClustalW for alignment of protein sequences using a unix system call
  system("clustalw  -gapopen=40 -output=gde -outorder=input -outfile=$nextdir/$name.gde -infile=$nextdir/$name.prot");

  #Run clustal for viewing alignment quality control checking
  system ("clustalw -gapopen=40 -outorder=input -infile=$nextdir/$name.prot");
  # Run sed expressions to replace : and % characters from ClustalW alignmnets
  # with and underscore and a fasta header
  system ("sed 's/:/_/g' $nextdir/$name.dna > $nextdir/dna_file");
  system("sed 's/%/>/g' $nextdir/$name.gde > $nextdir/protalign; sed 's/:/_/g' $nextdir/$name.dna > $nextdir/dna_file; cat $nextdir/protalign $nextdir/dna_file > $nextdir/catted");
  
  #Use the ClustalW amino acid alignment as a template for EMBOSS's tranalign
  #to place nucleotide codons onto amino acids generating in-frame codon alignments
  #for CODEML.
  system ("tranalign -asequence $nextdir/$name.dna -bsequence $nextdir/protalign -table 11 -outseq $nextdir/pre_infile");
  #convert DNA alignment to Phylip format for CODEML using readseq
  system("readseq -a -f=11 $nextdir/pre_infile > $nextdir/infile");
}
