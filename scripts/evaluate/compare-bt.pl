
my %basemodel = ();
my %btmodel = ();

while (<>){
    chomp;
    s/https:\/\/object\.pouta\.csc\.fi\/Tatoeba\-MT\-models\///;
    my @fields = split(/\t/);
    if ($fields[3]=~/^(.*)\+bt-....-..-..\.zip/){
	unless (exists $btmodel{"$fields[0]\t$1"}){
	    $btmodel{"$fields[0]\t$1"} = $_;
	}
    }
    elsif ($fields[3]=~/^(.*)-....-..-..\.zip/){
	unless (exists $basemodel{"$fields[0]\t$1"}){
	    $basemodel{"$fields[0]\t$1"} = $_;
	}
    }
}

foreach (sort keys %btmodel){
    if (exists $basemodel{$_} and $btmodel{$_}){
	print "base\t", $basemodel{$_},"\n";
	print "base+bt\t", $btmodel{$_},"\n";
	my @base = split(/\t/,$basemodel{$_});
	my @bt = split(/\t/,$btmodel{$_});
	$bt[1] = sprintf("%5.3f",$bt[1] - $base[1]);
	$bt[2] = sprintf("%5.2f",$bt[2] - $base[2]);
	print "diff\t", join("\t",@bt),"\n\n";
    }
}
