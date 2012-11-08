#!/usr/bin/perl

while (<>){
  if (/^>(.+)/){
    print "\n$1\t";
  }
  else {chomp; print $_;}
}
