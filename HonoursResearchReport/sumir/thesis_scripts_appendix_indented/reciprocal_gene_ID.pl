#!/usr/bin/perl -w
# initialise my paired accessions into variable
my $acc1 = ();
my $acc2 = ();
my $acc3 = ();
my $acc4 = ();
# open my first paired accession file
open(FILE1,$ARGV[0]) or die "Couldn’t open file 1\n";

while (<FILE1>) {
  chomp;
  @array1 = split; # split on white space to get two accessions per line
  my $acc1 = $array1[0]; #Strain A accession ID
  my $acc2 = $array1[1]; #Strain B accession ID

  open(FILE2,$ARGV[1]) or die "Couldn’t open file 1\n";
  while (<FILE2>) {
    chomp;
    @array2 = split;
    my $acc3 = $array2[0];  # Strain B accession ID
    my $acc4 = $array2[1]; # Strain A accession ID
    
    if(($acc1 eq $acc4) && ($acc2 eq $acc3)){# If the paired accession ID
      print "$acc1 $acc3\n"; # from list 1 match list 2 then print orthologous
    }                            # paired accessions for use
  }
  close FILE2;
}

close FILE1;
