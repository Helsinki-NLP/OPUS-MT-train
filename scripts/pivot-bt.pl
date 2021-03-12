#!/usr/bin/env perl
#


use strict;
use open qw/:std :utf8/;
use Getopt::Long;

my $AlphaOnly = 0;
my $WordOnly = 1;
my $LowerCase = 1;
my $verbose = 0;

my @SrcFiles = ();
my @SrcPivotFiles = ();
my @TrgPivotFiles = ();
my @TrgFiles = ();

GetOptions( 
    "srcfiles|s=s{,}"                  => \@SrcFiles,
    "srcpivotfiles|p1=s{,}"            => \@SrcPivotFiles,
    "trgpivotfiles|p2=s{,}"            => \@TrgPivotFiles,
    "trgfiles|t=s{,}"                  => \@TrgFiles,
    "alpha|a"                          => \$AlphaOnly,
    "word|w"                           => \$WordOnly,
    "lower-case|l"                     => \$LowerCase,
    "verbose|v"                        => \$verbose );


my %pivot2src = ();

while (@SrcFiles){
    my $srcfile = shift(@SrcFiles);
    my $srcpivot = shift(@SrcPivotFiles);

    print STDERR "read $srcfile $srcpivot ...\n";
    open S,"gzip -cd <$srcfile |" || die "cannot read from $srcfile";
    open T,"gzip -cd <$srcpivot |" || die "cannot read from $srcpivot";

    while (<S>){
	chomp;
	my $trg = <T>;
	chomp($trg);
	my $key = make_key($trg);
	$pivot2src{$key} = $_ if ($key);
    }
    close S;
    close T;
}


while (@TrgFiles){
    my $trgfile = shift(@TrgFiles);
    my $trgpivot = shift(@TrgPivotFiles);

    print STDERR "checking $trgfile $trgpivot ...\n";
    open S,"gzip -cd <$trgpivot |" || die "cannot read from $trgpivot";
    open T,"gzip -cd <$trgfile |" || die "cannot read from $trgfile";
    while (<S>){
	chomp;
	my $trg = <T>;
	chomp($trg);
	my $key = make_key($_);
	next unless ($key);
	if (exists $pivot2src{$key}){
	    print $pivot2src{$key},"\t",$trg,"\n";
	    print STDERR "matching key '$key'\n" if ($verbose);
	}
    }
    close S;
    close T;
}


sub make_key{
    my $string = shift;
    if ($AlphaOnly){
	$string=~s/\P{IsAlpha}//gs;
    }
    if ($WordOnly){
	$string=~s/\P{IsWord}//gs;
    }
    if ($LowerCase){
	$string=lc($string);
    }
    return $string;
}
