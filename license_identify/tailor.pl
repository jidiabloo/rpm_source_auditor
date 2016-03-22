#!/usr/bin/perl

use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Data::Dumper;
use Storable;

##this script loads a file list and remove them from exist scanning folder
$tailor_list_file = "/home/xji/mount_point/Source_Code_Audit/tailor_list.txt";
$csip_rpm_folder =  '/home/xji/mount_point/Source_Code_Audit/csip_folder';
$tailor_folder =  '/home/xji/mount_point/Source_Code_Audit/tailoring';

sub move_tailored_file{
    
    open my $info, $tailor_list_file or die "Could not open $tailor_list_file: $!";
    while( my $line = <$info>)  {
	chomp($line);
	my $pure_name = &get_pure_rpm_name($line);
	my $src_folder = `ls -d $csip_rpm_folder/$pure_name*`;
	chomp($src_folder);
	
	if( -e "$src_folder" ){
	    print "start to move the folder outside $src_folder\n";
	    
	    my $folder_base = basename($src_folder);
	    move($src_folder, "$tailor_folder/$folder_base");
	}else{
	    print "can not find src folder for $src_folder \n";
	}
    }
}


sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;

    return $result_strs[0];
}

&move_tailored_file
