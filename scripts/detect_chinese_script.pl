#!/usr/bin/env perl

use utf8;
use strict;
use Text::Iconv;
use Getopt::Std;
use vars qw/$opt_t $opt_v/;

getopts('t:v');

## threshold for length proportion
my $threshold = $opt_t || 0.8;


binmode(STDIN,"UTF-8");
binmode(STDOUT,"UTF-8");



my $utf8big5_converter1 = Text::Iconv->new("UTF-8", "big5//TRANSLIT");
my $utf8big5_converter2 = Text::Iconv->new("UTF-8", "big5//IGNORE");

my $utf8gb2312_converter1 = Text::Iconv->new("UTF-8", "gb2312//TRANSLIT");
my $utf8gb2312_converter2 = Text::Iconv->new("UTF-8", "gb2312//IGNORE");

# my $big5utf8_converter = Text::Iconv->new("big5", "UTF-8");
# my $gb2312utf8_converter = Text::Iconv->new("gb2312", "UTF-8");


while (<>){
    chomp;

    my $test1 = $utf8big5_converter1->convert($_);
    my $test2 = $utf8big5_converter2->convert($_);

    if ($test1 eq $test2){
	print "_Hant\n";
    }
    else {
	my $test3 = $utf8gb2312_converter1->convert($_);
	my $test4 = $utf8gb2312_converter2->convert($_);
	if ($test3 eq $test4){
	    print "_Hans\n";
	}
	else{
	    if ( (length($test3) * 0.8 < length($test4)) || (length($test4) * 0.8 < length($test3)) ) {
		print "_Hans\n";
	    }
	    elsif ( (length($test1) * 0.8 < length($test2)) || (length($test2) * 0.8 < length($test1)) ){
		print "_Hant\n";
	    }
	    else{
		print "\n";
		if ($opt_v){
		    print STDERR "unclear: $_ ";
		    print " (length big5   ",length($test1),"-",length($test2);
		    print ", length gb2312 ",length($test3),"-",length($test4),")\n";
		}
	    }
	}
    }
}

