#!/usr/bin/env perl
#
# simple script for filling/clipping data to a certain size
# in number of lines

use strict;
use Getopt::Std;

use vars qw/$opt_m/;

getopts('m:');

my $size = shift(@ARGV);
my $file = shift(@ARGV);

my $count=0;
my $repeated=0;
while ($count < $size){
    if ($file=~/\.gz$/){
	open F,"gzip -cd <$file |" || die "cannot open $file";
    }
    else{ open F,"<$file" || die "cannot read from $file!\n"; }    
    while (<F>){
	$count++;
	print;
	last if ($count >= $size);
    }
    close F;
    $repeated++;
    last if ($opt_m && $repeated > $opt_m);
}
