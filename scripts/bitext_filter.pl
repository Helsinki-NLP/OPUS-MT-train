#!/usr/bin/env perl
#
#
# bitext_filter.pl srclang trglang inputbase outputbase
# assumes that data is in 
#    inputbase.srclang.gz
#    inputbase.trglang.gz

use strict;
use Getopt::Std;
use vars qw/$opt_c $opt_l $opt_v/;

getopts('c:l:v');

my $CharLengthRatio = 2 || $opt_l;
my $UniqueCharRatio = 2 || $opt_c;


die "USAGE: bitext_filter.pl srclang trglang inputbase outputbase"
    unless ($#ARGV == 3);

my ($src, $trg, $inputbase, $outputbase) = @ARGV;

die "input and output have the same name" if ($inputbase eq $outputbase);


my $inputsrcfile = "$inputbase.$src.gz";
my $inputtrgfile = "$inputbase.$trg.gz";

my $outputsrcfile = "$outputbase.$src.gz";
my $outputtrgfile = "$outputbase.$trg.gz";


open SI,"gzip -cd <$inputsrcfile |" || die "cannot read from $inputsrcfile\n";
open TI,"gzip -cd <$inputtrgfile |" || die "cannot read from $inputtrgfile\n";

open SO,"| gzip -c >$outputsrcfile" || die "cannot read from $inputsrcfile\n";
open TO,"| gzip -c >$outputtrgfile" || die "cannot read from $inputtrgfile\n";


binmode(SI,":utf8");
binmode(TI,":utf8");
binmode(SO,":utf8");
binmode(TO,":utf8");
binmode(STDOUT,":utf8");
binmode(STDERR,":utf8");

my $count = 0;
my $skipped = 0;
my $skippedLength = 0;
my $skippedAlphabet = 0;

while (my $s = <SI>){
    $count++;
    unless ($opt_v){
	print STDERR '.' unless ($count % 100000);
	print STDERR " $count\n" unless ($count % 5000000);
    }

    my $t = <TI>;
    my $sl = length($s);
    my $tl = length($t);
    unless ($sl && $tl){
	$skipped++;
	next;
    }
    my $LengthRatio = $sl > $tl ? $sl/$tl : $tl/$sl;

    if ($LengthRatio > $CharLengthRatio){
	print STDERR "skip line $count (length ratio $LengthRatio > $CharLengthRatio)\n" if ($opt_v);
	$skipped++;
	$skippedLength++;
	next;
    }
    my %s = ();
    my %t = ();
    map { $s{$_}++ } split(//,$s);
    map { $t{$_}++ } split(//,$t);

    my $sa = scalar keys %s;
    my $ta = scalar keys %t;

    my $AlphabetRatio = $sa > $ta ? $sa/$ta : $ta/$sa;

    if ( $AlphabetRatio > $UniqueCharRatio ){
	print STDERR "skip line $count (unique char ratio $AlphabetRatio > $UniqueCharRatio\n" if ($opt_v);
	$skipped++;
	$skippedAlphabet++;
	next;
    }
    print SO $s;
    print TO $t;
}


print "\noriginal: $count\n";
print "skipped : $skipped\n";
print "   skipped because of character length ratio: $skippedLength\n";
print "   skipped because of alphabet size ratio   : $skippedAlphabet\n";
print "retained: ",$count-$skipped,"\n";
