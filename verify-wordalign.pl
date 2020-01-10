#!/usr/bin/env perl

my $srcfile = shift(@ARGV);
my $trgfile = shift(@ARGV);
my $algfile = shift(@ARGV);

open S,"gzip -cd < $srcfile |" || die "cannot open $srcfile";
open T,"gzip -cd < $trgfile |" || die "cannot open $trgfile";
open A,"gzip -cd < $algfile |" || die "cannot open $algfile";

my $count=0;
while (<A>){
    $count++;
    # chomp;
    s/^\s*//;
    s/\s*$//;

    my $src = <S>;
    my $trg = <T>;

    $src=~s/^\s*//;
    $src=~s/\s*$//;
    $trg=~s/^\s*//;
    $trg=~s/\s*$//;

    $src = split(/\s+/,$src);
    $trg = split(/\s+/,$trg);

    # my $src = split(/\s+/,<S>);
    # my $trg = split(/\s+/,<T>);

    print STDERR "empty source line $count" unless ($src);
    print STDERR "empty target line $count" unless ($trg);

    foreach (split(/\s+/)){
	my ($sidx,$tidx) = split(/\-/);
	print "line $count: invalid source index '$sidx'" unless ($sidx=~/^[0-9]+$/);
	print "line $count: invalid target index '$sidx'" unless ($tidx=~/^[0-9]+$/);
	if (($sidx < 0) or ($sidx > $src)){
	    print "line $count: source index out of range ($sidx/$src)\n";
	}
	if (($tidx < 0) or ($tidx > $trg)){
	    print "line $count: target index out of range ($tidx/$trg)\n";
	}
    }

    print STDERR '.' if (! ($count % 10000));
    print STDERR "$count\n" if (! ($count % 500000));

}
