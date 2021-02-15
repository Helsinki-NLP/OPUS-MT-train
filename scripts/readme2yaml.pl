#!/usr/bin/env perl
#
# quick and dirty script to
# convert information from README files
# to appropriate yaml-files


use strict;

my $model = undef;
my %modelinfo = ();

my $dir = shift(@ARGV);
$dir=~s/\/+$//;
my @parts = split(/\/+/,$dir);
my $langpair = pop(@parts);

open F,"<$dir/README.md" || die "cannot read $dir/README.md\n";

while (<F>){
    if (/^\# (.*)$/){
	$model = $1;
	$modelinfo{$model} = {};
	$model=~/^(.*)\-([0-9]{4}\-[0-9]{2}\-[0-9]{2})\.zip/;
	$modelinfo{$model}{'release'} = $langpair.'/'.$model;
	$modelinfo{$model}{'release-date'} = $2;
	$modelinfo{$model}{'dataset-name'} = $1;
    }
    if (/^* model: (\S+)$/){
	$modelinfo{$model}{'modeltype'} = $1;
    }
    if (/^* dataset: (\S+)$/){
	$modelinfo{$model}{'dataset-name'} = $1;
    }
    if (/^* source language\(s\): (.*)$/){
	@{$modelinfo{$model}{'source-languages'}} = split(/\s+/,$1);
    }
    if (/^* target language\(s\): (.*)$/){
	@{$modelinfo{$model}{'target-languages'}} = split(/\s+/,$1);
    }
    if (/^* pre\-processing: (.*)$/){
	$modelinfo{$model}{'pre-processing'} = $1;
	if ($modelinfo{$model}{'pre-processing'}=~/(.*) \((\S+),(\S+)\)$/){
	    $modelinfo{$model}{'subwords'}[0] = "source: $2";
	    $modelinfo{$model}{'subwords'}[1] = "target: $3";
	}
	if ($modelinfo{$model}{'pre-processing'}=~/SentencePiece/){
	    $modelinfo{$model}{'subword-models'}[0] = "source: source.spm";
	    $modelinfo{$model}{'subword-models'}[1] = "target: target.spm";
	}
	else{
	    $modelinfo{$model}{'subword-models'}[0] = "source: source.bpe";
	    $modelinfo{$model}{'subword-models'}[1] = "target: target.bpe";
	}
    }
    if (/^\|/){
	my @scores = split(/\s*\|\s*/);
	if ($scores[2]=~/[0-9]/){
	    push(@{$modelinfo{$model}{'BLEU-scores'}},$scores[1].': '.$scores[2]);
	    push(@{$modelinfo{$model}{'chr-F-scores'}},$scores[1].': '.$scores[3]);
	}
    }
}
close F;


## check modeltype from zip file if necessary
foreach my $m (keys %modelinfo){
    next unless (exists $modelinfo{$m}{'modeltype'});
    if (-e "$dir/$m"){
	my $dist = `unzip -l $dir/$m`;
	if ($dist=~/transformer-align/s){
	    $modelinfo{$m}{'modeltype'} = 'transformer-align';
	}
	else{
	    $modelinfo{$m}{'modeltype'} = 'transformer';
	}
    }
}


## add info about target language labels
foreach my $m (keys %modelinfo){
    if (exists $modelinfo{$m}{'target-languages'}){
	if ($#{$modelinfo{$m}{'target-languages'}}){
	    $modelinfo{$m}{'use-target-labels'} = [];
	    foreach (@{$modelinfo{$m}{'target-languages'}}){
		push(@{$modelinfo{$m}{'use-target-labels'}},'>>'.$_.'<<');
	    }
	}
    }
}

## print the yml files
foreach my $m (keys %modelinfo){

    my $yml = $m;
    $yml=~s/\.zip/\.yml/;
    next if (-e "$dir/$yml");

    print "write to $dir/$yml\n";
    open F,">$dir/$yml" || die "cannot write to $dir/$yml\n";

    foreach my $k ('release', 'release-date', 'dataset-name', 'modeltype',
		   'pre-processing', 'subwords', 'subword-models', 
		   'source-languages', 'target-languages',
		   'use-target-labels', 'BLEU-scores', 'chr-F-scores'){
	next unless (exists $modelinfo{$m}{$k});
	if (ref($modelinfo{$m}{$k}) eq 'ARRAY'){
	    print F "$k:\n";
	    foreach (@{$modelinfo{$m}{$k}}){
		print F "   - $_\n";
	    }
	}
	else{
	    print F "$k: $modelinfo{$m}{$k}\n";
	}
	delete $modelinfo{$m}{$k}
    }
    foreach my $k (sort keys %{$modelinfo{$m}}){
	if (ref($modelinfo{$m}{$k}) eq 'ARRAY'){
	    print F "$k:\n";
	    foreach (@{$modelinfo{$m}{$k}}){
		print F "   - $_\n";
	    }
	}
	else{
	    print F "$k: $modelinfo{$m}{$k}\n";
	}
    }
    close F;

}
