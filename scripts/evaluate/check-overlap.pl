#!/usr/bin/env perl

use utf8;
use strict;
use open qw/:std :utf8/;
use Getopt::Long;

my $AlphaOnly    = 0;
my $LowerCase    = 0;
my $DecodeSpm    = 0;
my $verbose      = 0;

GetOptions( 
    "alpha|a"                          => \$AlphaOnly,
    "lower-case|l"                     => \$LowerCase,
    "decode-spm|d"                     => \$DecodeSpm,
    "verbose|v"                        => \$verbose );

my $BigSrcFile = shift(@ARGV);
my $BigTrgFile = shift(@ARGV);

my %SrcSents = ();
my %TrgSents = ();
my %SentPairs = ();



while (@ARGV){
    my $SrcFile = shift(@ARGV);
    my $TrgFile = shift(@ARGV);
    read_pairs($SrcFile,$TrgFile);
}


my $S = open_file($BigSrcFile);
my $T = open_file($BigTrgFile);


my $total = 0;
my ($SrcExists,$TrgExists,$PairExists) = (0,0,0);
my %SrcUniqueExists = ();
my %TrgUniqueExists = ();
my %PairUniqueExists = ();


while (<$S>){
    my $trg = <$T>;
    &normalise($_);
    &normalise($trg);
    $total++;
    if (exists $SrcSents{$_}){
	$SrcExists++;
	$SrcUniqueExists{$_}++;
    }
    if (exists $TrgSents{$trg}){
	$TrgExists++;
	$TrgUniqueExists{$trg}++;
    }
    if (exists $SentPairs{"$_\t$trg"}){
	$PairExists++;
	chomp;
	unless (exists $PairUniqueExists{"$_\t$trg"}){
	    print STDERR "exists: $_\t$trg\n" if ($verbose);
	    $PairUniqueExists{"$_\t$trg"}++;
	}
    }
}

my $TotalSmall = scalar keys %SentPairs;
if ($total){
    printf "source sentences from train found in devtest\t%d\t%5.2f\%\n",$SrcExists,100*$SrcExists/$total;
    printf "target sentences from train found in devtest\t%d\t%5.2f\%\n",$TrgExists,100*$TrgExists/$total;
    printf "  sentence pairs from train found in devtest\t%d\t%5.2f\%\n",$PairExists,100*$PairExists/$total;
    print "total size of training data\t",$total,"\n";
}
if ($TotalSmall){
    my $SrcExistsSmall = scalar keys %SrcUniqueExists;
    my $TrgExistsSmall = scalar keys %TrgUniqueExists;
    my $PairExistsSmall = scalar keys %PairUniqueExists;
    printf "source sentences from devtest found in train\t%d\t%5.2f\%\n",$SrcExistsSmall,100*$SrcExistsSmall/$TotalSmall;
    printf "target sentences from devtest found in train\t%d\t%5.2f\%\n",$TrgExistsSmall,100*$TrgExistsSmall/$TotalSmall;
    printf "  sentence pairs from devtest found in train\t%d\t%5.2f\%\n",$PairExistsSmall,100*$PairExistsSmall/$TotalSmall;
    print "total size of devtest data\t",$TotalSmall,"\n";
}


sub read_pairs{
    my ($SrcFile,$TrgFile) = @_;
    my $S = open_file($SrcFile);
    my $T = open_file($TrgFile);
    while (<$S>){
	my $trg = <$T>;
	&normalise($_);
	&normalise($trg);
	$SrcSents{$_} = 1;
	$TrgSents{$trg} = 1;
	$SentPairs{"$_\t$trg"} = 1;
    }
    close $S;
    close $T;
}


sub open_file{
    my $file = shift;
    my $handle;
    if ($file=~/\.gz$/){
	open $handle,"gzip -cd <$file |" || die "cannot open $file\n";
	return $handle;
    }
    open $handle,"<$file" || die "cannot open $file\n";
    return $handle;
}


sub normalise{
    $_[0]=~s/\P{IsAlpha}//gs if ($AlphaOnly);
    $_[0] = lc($_[0]) if ($LowerCase);
    if ($DecodeSpm){
	if ($_[0]=~s/▁/ /g){
	    $_[0]=~s/ //g;
	}
    }
}
