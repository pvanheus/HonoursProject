#!/usr/bin/perl
use warnings;
use Cwd;
$maindir = getcwd();
#Initialse my working directories and make an ouput direcotiry containing parsed
# CODEML results
$dir = $ARGV[0];
$outdir = $ARGV[1];
system "mkdir $outdir";
opendir(DIR, "$maindir/$dir") or die "can't opendir";
while (defined($nextdir = readdir(DIR))) {
  if ($nextdir =~ /cluster_.+/)
    {
      print $nextdir, "\n" ;
      parse_codeml("$maindir/$dir/$nextdir", "$maindir/$outdir/$nextdir");
    }
}

closedir(DIR);

exit;
# Define my sub-routine to parse the CODEML results
sub parse_codeml{
  # Create CODEML results in output directory maintaining the same directory
  # structure as they were read in so I can track the cluster ID number
  my ($nextdir) = $_[0];
  my ($outdir) = $_[1];
  my @accessions = () ;
  # Open the CODEML results file
  open(CODEML, "$nextdir/outfile") || next;

  # Pattern match the CODEML results files for M1a and M2a reuslts and place into
  # a hash for look up
  while(<CODEML>) {
    if(/^#\d:\s(.+)\n/){
      push(@accessions, $1) ;
    }
    @array = split;
    if ($_ =~ /^Model\s[1|2]/){
      $w2 = $array[2] ;
    }
    elsif ($_ =~ /lnL/){
      chomp;
      $ratio = $array[4];
      if(defined $w2){
	$hash{$w2} = $ratio ;
      }
    }
  }
  close CODEML;
  # Determine if value of the LRT test is greater then 5.99
  # (P = 0.05 Chi-Square critical value with two degrees of freedom)
  if(log_likelihood(\%hash) > 5.99){
    open(RESULT_FILE, ">>$outdir") || die "Can't create file $outdir";
    print RESULT_FILE "@accessions\n" ;
    foreach (keys %hash){
      print RESULT_FILE "$_ $hash{$_}\n" ;
    }
    # If result of LRT greater then 5.99 then print paired accessions, Log liklihoods
    # for M1a and M2a and LRT value to a reults file
    print RESULT_FILE log_likelihood(\%hash), "\n" ;
    close RESULT_FILE;
  }
}

# Sub-routine to print paired accession IDs obtained from CODEML results file
sub print_hash{
  my %hash = $_[0] ;
  foreach (keys %hash){
    print "$_ $hash{$_}\n" ;
  }
}

# Sub-routine to perform the LRT test on log liklihoods of M1a and M2a models.
sub log_likelihood{
  my $hashref = $_[0] ;
  my %hash = %$hashref ;
  my $diff = 2*($hash{"PositiveSelection"} - ($hash{"NearlyNeutral"})) ;
  return($diff) ;
}