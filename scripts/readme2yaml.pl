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
	my @languages = split(/\s+/,$1);
	foreach (@languages){
	    s/[\-\_].*//;
	    $modelinfo{$model}{'source-languages'}{$_}++;
	}
    }
    if (/^* valid language labels: (.*)$/){
	@{$modelinfo{$model}{'use-target-labels'}} = split(/\s+/,$1);
    }
    if (/^* target language\(s\): (.*)$/){
	my @languages = split(/\s+/,$1);
	unless (exists $modelinfo{$model}{'use-target-labels'}){
	    if ($#languages){
		$modelinfo{$model}{'use-target-labels'} = [];
		foreach (@languages){
		    push(@{$modelinfo{$model}{'use-target-labels'}},'>>'.$_.'<<');
		}
	    }
	}
	foreach (@languages){
	    s/[\-\_].*//;
	    $modelinfo{$model}{'target-languages'}{$_}++;
	}
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
	next unless ($scores[2]=~/[0-9]/);

	## normalise the odd test set names
	if ($scores[1]=~/\.([^\.]+)\.([^\.]+)$/){
	    my ($s,$t) = ($1,$2);
	    $scores[1]=~s/[\-\.]$s\-?$t\.$s\.$t$/.$s.$t/;
	}
	$scores[1]=~s/\.([^\.]+)\.([^\.]+)$/.$1-$2/;

	if ($scores[2]=~/[0-9]/){
	    # push(@{$modelinfo{$model}{'BLEU-scores'}},$scores[1].': '.$scores[2]);
	    # push(@{$modelinfo{$model}{'chr-F-scores'}},$scores[1].': '.$scores[3]);
	    $modelinfo{$model}{'BLEU-scores'}{$scores[1].': '.$scores[2]}++;
	    $modelinfo{$model}{'chr-F-scores'}{$scores[1].': '.$scores[3]}++;
	}
	if (@scores > 3 && $scores[4]=~/[0-9]/){
	    # push(@{$modelinfo{$model}{'test-data'}},"$scores[1]: $scores[4]/$scores[5]");
	    $modelinfo{$model}{'test-data'}{"$scores[1]: $scores[4]/$scores[5]"}++;
	}
	elsif ($scores[1]=~/^(.*)\.([^\.]+)\-([^\.]+)$/){
	    my $testset = $1;
	    my ($src,$trg) = ($2,$3);
	    my ($lines,$words) = (0,0);
	    if ($testset eq 'Tatoeba-test'){
		if ($scores[1] eq 'Tatoeba-test' || $src eq 'multi' || $trg eq 'multi'){
		    my $evalfile = $model;
		    $evalfile=~s/\.zip/.test.txt/;
		    if (-e "models-tatoeba/$langpair/$evalfile" ){
			my $counts = `sed -n '2~4p' models-tatoeba/$langpair/$evalfile | wc -lw`;
			$counts=~s/^\s*//;
			($lines,$words) = split(/\s+/,$counts);
		    }
		}
		else{
		    ($lines,$words) = get_tatoeba_counts($src,$trg);
		}
	    }
	    elsif (-e "testsets/$src-$trg/$testset.$trg.gz"){
		my $counts = `zcat testsets/$src-$trg/$testset.$trg.gz | wc -lw`;
		$counts=~s/^\s*//;
		($lines,$words) = split(/\s+/,$counts);
	    }
	    $modelinfo{$model}{'test-data'}{"$scores[1]: $lines/$words"}++;
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


# ## add info about target language labels
# foreach my $m (keys %modelinfo){
#     if (exists $modelinfo{$m}{'target-languages'}){
# 	if ($#{$modelinfo{$m}{'target-languages'}}){
# 	    $modelinfo{$m}{'use-target-labels'} = [];
# 	    foreach (@{$modelinfo{$m}{'target-languages'}}){
# 		push(@{$modelinfo{$m}{'use-target-labels'}},'>>'.$_.'<<');
# 	    }
# 	}
#     }
# }


## print the yml files
foreach my $m (keys %modelinfo){

    my $yml = $m;
    $yml=~s/\.zip/\.yml/;
    next if (-e "$dir/$yml");

    print "write to $dir/$yml\n";
    open F,">$dir/$yml" || die "cannot write to $dir/$yml\n";

    foreach my $k ('release', 'release-date', 'dataset-name', 'modeltype',
		   'pre-processing', 'subwords', 'subword-models', 
		   'source-languages', 'target-languages', 'use-target-labels', 
		   'training-data', 'validation-data', 'test-data',
		   'BLEU-scores', 'chr-F-scores'){
	next unless (exists $modelinfo{$m}{$k});
	if (ref($modelinfo{$m}{$k}) eq 'ARRAY'){
	    print F "$k:\n";
	    foreach (@{$modelinfo{$m}{$k}}){
		print F "   - $_\n";
	    }
	}
	elsif (ref($modelinfo{$m}{$k}) eq 'HASH'){
	    print F "$k:\n";
	    foreach (sort keys %{$modelinfo{$m}{$k}}){
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
	elsif (ref($modelinfo{$m}{$k}) eq 'HASH'){
	    print F "$k:\n";
	    foreach (sort keys %{$modelinfo{$m}{$k}}){
		print F "   - $_\n";
	    }
	}
	else{
	    print F "$k: $modelinfo{$m}{$k}\n";
	}
    }
    close F;

}

sub get_tatoeba_counts{
    my ($src,$trg) = @_;
    my $pair = $src lt $trg ? "$src-$trg" : "$trg-src";
    my $counts = '';
    if ($src lt $trg){
	$counts = `wget -qq -O - https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master/data/test/$src-$trg/test.txt | cut -f4 | wc -lw`;
    }
    else{
	$counts = `wget -qq -O - https://raw.githubusercontent.com/Helsinki-NLP/Tatoeba-Challenge/master/data/test/$trg-$src/test.txt | cut -f3 | wc -lw`;
    }
    $counts=~s/^\s*//;
    return split(/\s+/,$counts);
}
