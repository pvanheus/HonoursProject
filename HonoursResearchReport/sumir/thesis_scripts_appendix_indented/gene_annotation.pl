#!/usr/bin/env perl

use File::Find;
$annotation = shift;
find(\&wanted, ".");

sub wanted {
  my $file  = $_;
  return if -d $_;
  return unless /^cluster_/;
  open FH, $file or die "Can not open file :-(", $!;
  my $str = <FH>;
  my ($acc) = $str =~ /(HP\w+)/;
  close FH;
  parse_annot_file($acc, $annotation);
}

sub parse_annot_file {
  my ($acc, $annotation) = @_;
  open ANN, $annotation or die "xx ", $!;
  while ($line = <ANN>) {
    print $line if $line =~ /$acc/;
  }
}

sub ggg {
  my ($acc) = @_;
  open ANN, $annotation or die "xx ", $!;
  while ($line = <ANN>) {
    print $line if $line =~ /$acc/;
  }
}

