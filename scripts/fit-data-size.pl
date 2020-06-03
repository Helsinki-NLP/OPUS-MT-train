#!/usr/bin/env perl
#
# simple script for filling/clipping data to a certain size
# in number of lines

use strict;

my $size = shift(@ARGV);
my $file = shift(@ARGV);

my $count=0;
while ($count < $size){
    open F,"<$file" || die "cannot read from $file!\n";
    while (<F>){
	$count++;
	print;
	last if ($count >= $size);
    }
}
