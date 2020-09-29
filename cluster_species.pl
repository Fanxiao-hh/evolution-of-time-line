use Getopt::Long;

if($ARGV[0]=~m/-h/) {&Usage;exit;}

our $sequenceID;
our $speciesorder;
our $orthofile;
our $AIresult;
our $ai;
our $hu;
our $value;
our $minsum;
our $path=`pwd`;
chomp $path;
GetOptions(
#"sequenceID|ID:s" => \$sequenceID,
#"speciesorder|so:s" => \$speciesorder,
#"orthofile|og:s" => \$orthofile,
#"AIresult|A:s"  => \$AIresult,
"value|v:s" => \$value,
"AI:s" => \$ai,
"hu:s" => \$hu,
"minsum|m:s" => \$minsum,
);

#unless (defined $AIresult){&Usage;exit;}
unless (defined $value){&Usage;exit;}
#unless (defined $sequenceID){&Usage;exit;}
#unless (defined $speciesorder){&Usage;exit;}
#unless (defined $orthofile){&Usage;exit;}
unless (defined $ai){&Usage;exit;}
unless (defined $hu){&Usage;exit;}

my $AIresult="a".$ai."_h".$hu."gene";
my $AIresultstat="a".$ai."_h".$hu."stat";
my $orthofile=$path."/data/I1.2-out_orth-new-2-ok";
my $sequenceID=$path."/data/SequenceIDs-2";
my $speciesorder=$path."/data/speciesorder";
my $orthofile_filter=$AIresult."-".$value."-ortho";
my $orthofile_filter_num=$AIresult."-".$value."-ortho_number";
my $visualization_data=$orthofile_filter_num."_Gene_count";
my $timeline_final=$path."/data/timeline";
my $rankorder=$path."/data/rankrelation";
my $aifilesdir=$path."/data/hgt_filter_4";
my $kindomterms=$path."/data/terms";
my $pdffile=$visualization_data.".pdf";
my $tablefile=$visualization_data.".xls";
my $fasfile=$visualization_data.".fas";

my $scr_AI_time=$path."/scr/AI_time.pl";
my $scr_PAC_filter=$path."/scr/0.PCA-filter.pl";
my $scr_repalce_geneid=$path."/scr/1.replacegeneid.pl";
my $scr_transformat=$path."/scr/2.transformat.pl";
my $scr_visualization=$path."/scr/PCA.visualization.r";

my $log0=$AIresult."_".$value.".log0";
my $log1=$orthofile_filter.".log1";
my $log2=$orthofile_filter_num.".log2";


unless(-e $AIresultstat){
	print "there is no AI result, we need to run AI_time.pl\n";
	system("perl $scr_AI_time -t $timeline_final -r $rankorder -fp $aifilesdir -AI $ai -hu $hu -term $kindomterms");
}	
if(-e $AIresultstat){
	print "there is the AI result, we need to run 0.PCA-filter.pl next.\n";
	print $log0."\n";
	unless(-e $log0){
		print $log0."\n";
	system("perl $scr_PAC_filter -A $AIresult -v $value -og $orthofile"); #this step filter the genes in orthologous groups according to the time,generating the $orthofile."-".$value."-ortho" file;	
	}
	print "finish running 0.PCA-filter.pl. \n";
}


if(-e $log0){
	print "log0 file is detected, we need to run 1.replacegeneid.pl.\n ";
	unless(-e $log1){
	system("perl $scr_repalce_geneid -ID $sequenceID -og $orthofile_filter");
}
print "finish 1.replacegeneid.pl. \n";
} #this step replace the gene id to numbers for the next step;



if(-e $log1){
print "log1 file is detected, we need to run 2.transformat.pl.\n";
	unless(-e $log2){
system("perl $scr_transformat -ID $sequenceID -og $orthofile_filter_num -so $speciesorder");
}#this step count the orthologous and transform the gene ids.
print "finish 2.transformat.pl. \n";
}

if(-e $log2){
	print "log2 file is detected, we need to run PCA.visualization.r \n";
	unless(-e $tablefile){
system("Rscript $scr_visualization -d $visualization_data -m $minsum");
print $scr_visualization."\t".$visualization_data."\t".$minsum."\n";
}
print "finish PCA.visualization.r \n";
}


if(-e $tablefile){
print "table file is detected, we need to covert is to fas file. \n";
unless (-e $fasfile){
system("perl -pe 's/\"/\>/;s/\"/\n/' $tablefile > $fasfile");

}

print "fas file is ready, please use is to build the splitstree using Splitstree.5. \n";
}




sub Usage {
print <<End ;
The scripts is $0;
Usage:  
  perl $0 -ID sequenceID -og a30h90 -so specieorder
              -h/help	print the Usage;
              -AI	[num] 	the alien index to filter the genes;
              -hu	[num]	the hu index to filter the genes
              -v/value 	time value below which you dicide to drop;
              -m/minsum	the minmal sum number contained by each orthologous group use to PCA visualiztion. 
End
}





