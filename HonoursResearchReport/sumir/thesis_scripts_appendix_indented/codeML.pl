#!/usr/bin/perl
use Cwd;
$maindir = getcwd();
# initialise my directory to be specified from the command line
$dir = $ARGV[0];
# create a progress log to determine if all directories have been processed by
# codeML
open (LOG, ">progress.log_validation");
opendir(DIR, "$maindir/$dir") or die "can't opendir";
# Look for directories called cluster_ containing in-frame codon aligned files
while (defined($nextdir = readdir(DIR))) {
  if ($nextdir =~ /cluster_.+/)
    {
      print $nextdir;
      run_codeML("$maindir/$dir/$nextdir");
    }
}

closedir(DIR);

exit;
# define my subroutine run_codeML to feed my infile to codeML and a pre-specifed
# codeML control file specifying models M1a and M2a
sub run_codeML{
  my ($nextdir) = $_[0];

  print "**************** $nextdir\n";
  @dir_array = split(/\//, $nextdir);

  #temporarily copy Phylip format infile from working directory
  system ("cp $nextdir/infile $maindir");

  #Run codeML
  system ("codeml pipe.ctl");

  #move codeML results file to working directory
  system ("mv outfile_results 2ML.ds 2ML.dn $nextdir");
  #system "mv out.tree rst $nextdir";
  print LOG "$nextdir processed\n";
}
