#!/usr/bin/perl

if ($#ARGV < 3){
  die "\n\nusage: makeClusters.pl <blastclust_outfile> <DNA-table format> <PROTEIN-TABLE FORMAT> <output dir> \n\n\t\tNote: Sequence files in TABLE FORMAT eg. \nseq1  AGTCCATTCCAGG\nseq2  AGTGGGGGCAGG\n";
}

# initialise my variables
$clusterfile = $ARGV[0]; # paired orthlogous accession ID list
$dna = $ARGV[1]; # DNA sequences strain A and B in Table format
$protein = $ARGV[2]; # Protein sequences strain A and B in Table format
$outdir = $ARGV[3]; # Output direcotory

system "mkdir $outdir"; # Unix system call to create output directory

#Read DNA sequence and accession IDs into a hash table for quick retrieval
open(DNA, "$dna");
%dna_seqs = ();
while(<DNA>){
  @array1 = split;
  $dna_seqs{$array1[0]} = $array1[1];
}
close DNA;

#Read protein sequence and accession IDs into a hash table for quick retrieval
open(PROT, "$protein");
%prot_seqs = ();
while(<PROT>){
  @array2 = split;
  $prot_seqs{$array2[0]} = $array2[1];
}
close PROT;

#Grab each accession ID from paired accession cluster file and fetch
#sequences from hash table using accession IDs as a key from hash tables
#Write to a modified fasta file with each sequence on one line
open(CLUSTS, "$clusterfile");
while(<CLUSTS>){
  @array = split;
  $name1 = $array[0];
  $name2 = $array[1];
  ++$num;
  $outfile = "cluster_" . "$num";
  # write out .dna amd .prot files into outfile in directory
  mkdir("$outdir/$outfile",0777);
  open(DNA_OUT, ">$outdir/$outfile/$outfile.dna");
  open(PROT_OUT, ">$outdir/$outfile/$outfile.prot");
  # pull out my DNA and amino acid sequences for the given accession ID key for
  # strain A
  foreach $name(@array){
    if ($name =~ /$name1/){
      $dnaseq1 = $dna_seqs{$name};
      for ($i = 1, $i <= 3, ++$i) {
	chop($dnaseq1); # reomove stop codons for CODEML
      }
      $dna1 = ">$name\n$dnaseq1\n";
      $prot1 = ">$name\n$prot_seqs{$name}\n";
    }
    # pull out my DNA and amino acid sequences for the given accession ID key for
    # strain B
    elsif ($name =~ /$name2/){
      $dnaseq2 = $dna_seqs{$name};
      for ($i = 1, $i <= 3, ++$i) {
	chop($dnaseq2);
      }
      $dna2 = ">$name\n$dnaseq2\n";
      $prot2 = ">$name\n$prot_seqs{$name}\n";
    }
  }
  #print my orthlogous DNA sequences into a .dna file
  #print my orthlogous amino acid sequences in a .prot file
  print DNA_OUT "$dna1$dna2";
  print PROT_OUT "$prot1$prot2";
  close DNA_OUT;
  close PROT_OUT;
}
