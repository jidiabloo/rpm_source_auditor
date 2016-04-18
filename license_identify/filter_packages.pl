#!/usr/bin/perl
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;

sub filter_result_folder(){
    my $res_folder;
    #Go through the source folder
    opendir my $dh, $res_folder or die "Can not open $source_rpm_insight_folder: $!";

    foreach $file(readdir $dh) {
	$_ = $file;
	

	if( -d "$location/$file" ){
	    #print "find spec file in $file \n";	     
	    my $source_folder = "$location$file";

	    $package_number = $package_number + 1;
	    collect_license($source_folder);
	}
    }
}


sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;

    return $result_strs[0];
}

sub move_filtered_file{
    
    my $filter_list_file="";
    
    open my $info, $filter_list_file or die "Could not open $tailor_list_file: $!";
    while( my $line = <$info>)  {
	chomp($line);
		
	print "start to move the folder outside $csip_rpm_folder/$pure_name*\n";
	
	$matched_file=`file $line*`;
	
	unless( $matched_file eq "" ){
	    print "got a file about to be removed : $matched_file";   
	}

	#my $folder_base = basename($src_folder);
	system("mv $csip_rpm_folder/$pure_name* $tailor_folder");
	
    }
}
