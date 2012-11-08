#!/usr/bin/perl

# AUTHOR:Mbandi 2011
# LAST REVISED: 2012
# The Regents of christoffels_lab 
#South African National Bioinformatics Institute

#Runs velveth followed by oases for multiple values of k and calculates N50 stats
#File must be in fastA format else change -fasta to -fastq for fastQ files
use strict;
use warnings;

if (@ARGV!= 5) {
	print STDERR "usage: perl symbolic.velveth.pl shuffle.file.fa single.file.fa kmer1 kmer2 N50.stats.txt\n";
	print STDERR "kmer2 must be and odd number\n";
	exit(1)
}
my $time = time; 
my $shuffle = $ARGV[0];
my $single = $ARGV[1];
my $klow = $ARGV[2];
my $khigh = $ARGV[3];
my $stats = $ARGV[4];

if($khigh < $klow) {
	print STDERR "$khigh must be greater than $klow\n";
	exit(1)
}
$khigh++;

#initiates velveth for preparing files required by velvetg
system "velveth dir $klow,$khigh,2 -fasta -shortPaired $shuffle -short $single";

for(my $i=$klow; $i < $khigh; $i +=2) {
	#de bruign creation
	system"velvetg dir_$i  -unused_reads yes -read_trkg yes -scaffolding no -ins_length 118 -ins_length_sd 64 -amos_file yes";
	#-min_contig_lgth 100
	
	#transcript reconstruction
	system "oases dir_$i -amos_file yes -unused_reads yes -scaffolding no -ins_length 118 -ins_length_sd 64";
	#-ins_length 300 
	
	#assigns directory contig.fa file associated with  each k iteration
	my $contig = "./dir_$i/transcripts.fa";
	my ($len,$total)=(0,0);
	my @x;
	open (F,  $contig) || die "$contig does not exist\n";
	open (E, " >>$stats") || die "$stats does not exist\n";
	while(<F>){
		if(/^[\>\@]/){
			if($len>0){
				$total+=$len;
				push @x,$len;
			}
			$len=0;
		}
		else{
			s/\s//g;
			$len+=length($_);
		}
	}
	if ($len>0){
		$total+=$len;
		push @x,$len;
	}
	@x=sort{$b<=>$a} @x; 
	my ($count,$half)=(0,0);
	for (my $j=0;$j<@x;$j++){
		$count+=$x[$j];
		if (($count>=$total/2)&&($half==0)){
			print E "$contig\tN50: $x[$j]\n";
			$half=$x[$j]
		}
	}
	close F;
	close E;
}
$time = time - $time;

if($time < 60) {
	print  "Total time elapsed: $time secs.\n";
}
elsif (($time >= 60) && ($time < 3600)) {
	$time = $time/60;
	print  "Total time elapsed: $time mins.\n";
}
else { 
	$time = $time/3600;
	print  "Total time elapse: $time hours.\n";
}
