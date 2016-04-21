#!/usr/bin/perl
use Encode;
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;


#Added by jidiablo: those two line below is added for enabling the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';


$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: fetch_license_info_from_spec.pl /path/to/souce_folder \n";
    exit;
} 

$location=$ARGV[0];
 
print "We got argument: $location \n";

$package_number=0;


sub fetch_license_info()
{
    #Go through the source folder
    opendir my $dh, $location or die "Can not open $source_rpm_insight_folder: $!";
    
    
    foreach $file(readdir $dh) {
	$_ = $file;
	#print "dddd $file\n";
	if( -d "$location/$file" ){
	    #print "find spec file in $file \n";	     
	    my $source_folder = "$location$file";

	    $package_number = $package_number + 1;
	    collect_license($source_folder);
	}
    }
}

sub collect_license()
{
    my $source_folder = $_[0];
    @source_results = `ls $source_folder`;

    
    
    foreach (@source_results){
	if(/\.spec/){
	    #print "cached an spec file: $_ \n";
	    &parse_spec_file("$source_folder/$_", $rpm_folder);
	}
    }
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub parse_spec_file{
    my $spec_file = $_[0];
    my $rpm_folder = $_[1];
    open(SF, "$rpm_folder/$spec_file") or die("Could not open file.");

    my $pak_name;
    my $licenses;
    
    $count = 0;
    foreach $line(<SF>) {
	chomp($line);
	$_ = trim($line);
	
	if(/Name\:/){
	    my $index1 = rindex($_," ");
	    my $index2 = rindex($_,"\t");
	    
	    if($index1 > $index2){
		$name_index = $index1;
	    }else{
		$name_index = $index2;
	    }
	    
	    $pak_name = substr($_, $name_index+1);

	    if($pak_name ne ''){
		#print "we got a package Name: $pak_name";
		
	    }else{
		print "Error: $_   :  index1 : $index1 : index2: $index2 : nameIndex :  $name_index";
	    }	    
	}


	if(/License\:/){
	    my $index1 = index($_," ");
	    my $index2 = index($_,"\t");
	    
	    if($index1 > $index2){
		$name_index = $index1;
	    }else{
		$name_index = $index2;
	    }
	    
	    $license_info = substr($_, $name_index+1);
	    $license_info = trim($license_info);
	    
	    if($license_info ne ''){
		$licenses = "$licenses : $license_info"; 
		#print "got license info for $spec_file : $license_info\n";
	    }else{
		print "Error: $_   :  index1 : $index1 : index2: $index2 : nameIndex :  $name_index";
	    }
	}
    }

    print "$pak_name :: $licenses \n";
    close(SF);
}

&fetch_license_info;
