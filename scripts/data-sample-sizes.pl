#!/usr/bin/env perl
#
# determine data sample size with temperature
#
# -w ... gives the sample weight (equivalent to 1/T)       (default = 0.2, i.e. T=5)
# -m ... gives the maximum size for a langpair data subset (defaul = biggest langpair)


use strict;
use Getopt::Std;

use vars qw/$opt_w $opt_m/;

getopts('w:m:');

my $weight = $opt_w || 0.2;



## read data size

my %size = ();
my $maxsize = 0;
my $total = 0;

while (<>){
    chomp;
    my ($l,$s) = split(/\t/);
    if ($l eq 'TOTAL'){
	$total = $s;
    }
    else{
	$size{$l} = $s;
	$maxsize = $s if ($s > $maxsize);
    }
}

$maxsize = $opt_m if ($opt_m);


## get the weight-adjusted samples size

my %rate = ();
my %samplesize = ();
my $maxsample = 0;

foreach (sort keys %size){
    $rate{$_} = $total > 0 ? ($size{$_}/$total)**$weight : 0;
    $samplesize{$_} = int($total*$rate{$_});
    # print "sample size: $_\t$samplesize{$_}\t$rate{$_}\t$size{$_}\n";
    if ($samplesize{$_} > $maxsample){
	$maxsample = $samplesize{$_};
    }
}


## normalise size

my $factor = $maxsample > 0 ? $maxsize / $maxsample : 0;
# print "$factor = $maxsize / $maxsample\n";
foreach (sort keys %size){
    print "$_\t",int($samplesize{$_}*$factor),"\n";
}
