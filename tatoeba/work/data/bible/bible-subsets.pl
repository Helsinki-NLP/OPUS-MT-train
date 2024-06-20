#!/usr/bin/env perl


use strict;
use File::Basename;

my $MinSize = 50;
my $MinNrOfLangs = 2;
my $MinNrOfBibles = 100;

my %biblelines = ();
my %langlines = ();
my %linebibles = ();
my %linelangs = ();

foreach my $file (@ARGV){
    my ($lang) = split(/\-/,basename($file));
    open F,"<$file" || die "cannot open file $file\n";
    my $line=-1;
    while (<F>){
	chomp;
	$line++;
	next unless $_;
	next if ($_ eq 'BLANK');

	$biblelines{$file}{$line}++;
	$langlines{$lang}{$line}++;
	$linebibles{$line}{$file}++;
	$linelangs{$line}{$lang}++;
    }    
    close F;
}


## get subsets in terms of lines that are covered in at least one Bible

my %linesets = ();

foreach (keys %biblelines){
    my @set = sort {$a <=> $b} keys %{$biblelines{$_}};
    my $key = join(':',@set);
    $linesets{$key}{$_} = 1;
}


## add bibles that also cover the same lines (or more)

foreach my $lineset (keys %linesets){
    # print STDERR "check lineset\n";
    my @supersets = find_supersets($lineset, \%linesets);
    foreach my $set (@supersets){
	foreach my $bible (keys %{$linesets{$set}}){
	    $linesets{$lineset}{$bible} = 1;
	}
    }
}


my %subsets = ();

foreach my $lineset (keys %linesets){
    my %langs = get_bible_langs($linesets{$lineset});
    # my $langstr = join(':',sort keys %langs);
    # my $biblestr = join(':',sort keys %{$linesets{$lineset}});
    
    my $nrlines = scalar split(/\:/,$lineset);
    my $nrbibles = scalar keys %{$linesets{$lineset}};
    my $nrlangs = scalar keys %langs;

    if (exists $subsets{$nrlangs}{$nrlines}{$nrbibles}){
	print STDERR "subset exists already for $nrlines lines, $nrlangs languages, and $nrbibles bibles\n";
    }
    else{
	$subsets{$nrlangs}{$nrlines}{$nrbibles} = $lineset;
    }
    
    # if (exists $subsets{$nrlines}{$nrlangs}{$nrbibles}){
    # 	print STDERR "subset exists already for $nrlines lines, $nrlangs languages, and $nrbibles bibles\n";
    # }
    # else{
    # 	$subsets{$nrlines}{$nrlangs}{$nrbibles} = $lineset;
    # }
    
    # print "$nrlines\t$nrbibles\t$nrlangs\t$lineset\t$langstr\t$biblestr\n";
}


## for each corpus size: get the subset that covers most languages and bibles

# foreach my $nrlines (sort {$b <=> $a} keys %subsets){
#    my ($nrlangs) = sort {$b <=> $a} keys %{$subsets{$nrlines}};
    # my ($nrbibles) = sort {$b <=> $a} keys %{$subsets{$nrlines}{$nrlangs}};
    # my $lineset = $subsets{$nrlines}{$nrlangs}{$nrbibles};
    # my %langs = get_bible_langs($linesets{$lineset});
    # my $langstr = join(':',sort keys %langs);
    # my $biblestr = join(':',sort keys %{$linesets{$lineset}});
    # print "$nrlines\t$nrlangs\t$nrbibles\t$lineset\t$langstr\t$biblestr\n";


foreach my $nrlangs (sort {$b <=> $a} keys %subsets){
    my ($nrlines) = sort {$b <=> $a} keys %{$subsets{$nrlangs}};
    my ($nrbibles) = sort {$b <=> $a} keys %{$subsets{$nrlangs}{$nrlines}};
    my $lineset = $subsets{$nrlangs}{$nrlines}{$nrbibles};
    my %langs = get_bible_langs($linesets{$lineset});
    my $langstr = join(':',sort keys %langs);
    my $biblestr = join(':',sort keys %{$linesets{$lineset}});
    print "$nrlines\t$nrlangs\t$nrbibles\t$lineset\t$langstr\t$biblestr\n";

    # foreach my $nrlangs (sort {$b <=> $a} keys %{$subsets{$nrlines}}){
    # 	foreach my $nrbibles (sort {$b <=> $a} keys %{$subsets{$nrlines}{$nrlangs}}){
    # 	    my $lineset = $subsets{$nrlines}{$nrlangs}{$nrbibles};
    # 	    my %langs = get_bible_langs($linesets{$lineset});
    # 	    my $langstr = join(':',sort keys %langs);
    # 	    my $biblestr = join(':',sort keys %{$linesets{$lineset}});
    # 	    print "$nrlines\t$nrbibles\t$nrlangs\t$lineset\t$langstr\t$biblestr\n";
    # 	}
    # }
}



sub get_bible_langs{
    my $bibles = shift;
    my %langs = ();
    foreach (keys %{$bibles}){
	my ($lang) = split(/\-/,basename($_));
	$langs{$lang}++;
    }
    return %langs;
}


sub key2set{
    my ($setkey) = @_;
    my %set = ();
    foreach (split(/\:/,$setkey)){
	$set{$_} = 1;
    }
    return %set;
}

sub is_included{
    my ($set1, $set2) = @_;
    foreach (keys %{$set1}){
	if (! exists $$set2{$_}){
	    # print STDERR "line $_ does not exist in set 2\n";
	    return 0;
	}
	# return 0 unless (exists $$set2{$_});
    }
    return 1;
}

sub find_supersets{
    my ($set, $sets) = @_;
    my @supersets = ();

    my %set1 = key2set($set);    
    foreach my $s (keys %{$sets}){
	my %set2 = key2set($s);
	if (is_included(\%set1, \%set2)){
	    push(@supersets,$s);
	}
    }
    return @supersets;
}


