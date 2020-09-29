
use strict;
use warnings;
use Getopt::Long;
use List::MoreUtils ':all';

our $value;
our $AIresult;
our $orthofile;
our %hash;
our %hashs;


if($ARGV[0]=~m/-h/) {&Usage;exit;}


GetOptions(
"AIresult|A:s"     => \$AIresult,
"value|v:s" => \$value,
"orthofile|og:s" => \$orthofile,
);
if (defined $AIresult){}else{&Usage;exit;}
if (defined $value){}else{&Usage;exit;}
if (defined $orthofile){}else{&Usage;exit;}

open IN1,"<$orthofile" or die $!; #this loop read orthlogous files;
while(<IN1>){
chomp;	
if(/^([0-9]+)\s+(.*)\s+\$/){
my $OG=$1;
my $line=$2;
my @ele =split / /, $line;
foreach my $elements(@ele){
$hash{$elements}=$OG;
$hashs{$OG}=$line;	
}
}
}
close IN1;

print "successfully read orthologfiles\n";

open IN2, "<$AIresult" or die $!; #this loop read ai-result and filter the genes according to the time;

while(<IN2>){
	unless(/\#/){
chomp;
my $line =$_;
my @elements=split /\t/,$line;
my $gene=$elements[2];
$gene=~s/\@\@\S+//;
my $reciptortime=$elements[5];
my $reciptorfathertime=$elements[6];
if($reciptortime=~/NA/){
if($reciptorfathertime<$value){
	#print $gene."\t".$reciptorfathertime."\n";

		my $og=$hash{$gene};
		$hashs{$og}=~s/ $gene / /;
		#delete $hash{$gene};
}
	}else{
		if($reciptortime<$value){
			my $og=$hash{$gene};
			$hashs{$og}=~s/ $gene / /;
			#delete $hash{$gene};
			#print $gene."\t".$reciptortime."\n";
		}
	}
}
}
close IN2;
print "successfully filter the gene according to thier time\n";

my $outfile=$AIresult."-".$value."-ortho"; #this loop make a new orthologous file;
open OUT, ">$outfile" ; 
foreach my $key (sort keys %hashs){
	print OUT $key."\t";
	print OUT $hashs{$key};
		print OUT "\$\n";
}

my $log0=$AIresult."_".$value.".log0";
open LOG,"> $log0";
print LOG "finish 0.PCA-filter.pl. \n";

sub Usage {
print <<End ;
The scripts is $0;
Usage:  
  perl $0 -A a30_h90gene -v 100 -og I1.2-out_orth-new-2-ok
               -h/help	print the Usage;
               -A/AIresult	a30h90 result;
               -v/value 	time value below which you dicide to drop;
               -og 	orthologous file.
End
}

