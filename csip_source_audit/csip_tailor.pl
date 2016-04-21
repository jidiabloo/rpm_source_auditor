#!/usr/bin/perl

use File::Remove 'remove';
use Archive::Extract;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Data::Dumper;
use Storable;

##This script loads a file list and remove them from exist scanning folder
$filter_list_file="../file_list/filter_list";
$tailor_list_file = "/home/xji/mount_point/Source_Code_Audit/tailor_list.txt";
$csip_rpm_folder =  '/home/xji/mount_point/Source_Code_Audit/csip_folder';
$tailor_folder =  '/home/xji/mount_point/Source_Code_Audit/tailoring';

sub test{
    my $arch="/home/xji/mount_point/Source_Code_Audit/csip_folder/icu-4.6.skytree27-1.1.8.src.rpm/icu-4.6.skytree27.tar.gz"; 
        
    my $ae = Archive::Extract->new( archive => "$arch" );
    print "start to extract !!! $arch";

    my $ok = $ae->extract( to => './tmp' );
}

#extract all the tar archive in csip folder
#remove src.rpm file in csip folder
sub extract_file{
    #Todo: Remove all the src.rpm file
    system "find $csip_rpm_folder -name '*.src.rpm'";
    
    opendir my $dh, $csip_rpm_folder or die "Can not open $csip_rpm_folder: $!";
    
    foreach $file (readdir $dh) {
	$_ = $file;
	##Todo: list each folder here
	
	my @flist = `ls $csip_rpm_folder/$_`;
	
	foreach $fitem (@flist){
	    
	    $_ = $fitem;
	    if(/\.src\.rpm/){
		unless(-d "$csip_rpm_folder/$file/$fitem"){
		    print " remove !!! $csip_rpm_folder/$file/$_\n";
		    remove("$csip_rpm_folder/$file/$_");
		}
	    }
	    
	    if( /\.tar\.gz/ || /\.tar\.bz2/ ){
		print "Start to extract archive :: $_";
		system("cd $csip_rpm_folder/$file; tar -xvf $_");	
	    }
	    
	    if( /\.xz/ ){
		print "Start to extract archive :: $_";
		
		system("cd $csip_rpm_folder/$file; xz -d $_");
		
		my @tar_name_list = `cd $csip_rpm_folder/$file; ls *.tar`;
		foreach $item (@tar_name_list){
		    system("cd $csip_rpm_folder/$file; tar -xvf $item");
		}
		
	    }
	}
    }
}

sub move_tailored_file{
    
    open my $info, $tailor_list_file or die "Could not open $tailor_list_file: $!";
    while( my $line = <$info>)  {
	chomp($line);
	my $pure_name = &get_pure_rpm_name($line);
		
	print "start to move the folder outside $csip_rpm_folder/$pure_name*\n";
	    
	#my $folder_base = basename($src_folder);
	system("mv $csip_rpm_folder/$pure_name* $tailor_folder");
	
    }
}


sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;

    return $result_strs[0];
}

my @search_pattern=('*.jpg','*.png','*.gif','*.qrc','*.src.rpm','*tar.bz2','*.tar.gz','*.xz','*.tar');
#my @search_folder_pattern=('tests','test','doc','upstream','.git' );
my @search_folder_pattern=('upstream','.git' );

sub remove_non_scan_file{
    
    for $item (@search_pattern){
	print "find $csip_rpm_folder -name '$item' \n";
	system "find $csip_rpm_folder -type f -name '$item' | xargs -Ixxx rm xxx";
    }

    for $item (@search_folder_pattern){
	print "find $csip_rpm_folder -name '$item' \n";
	system "find $csip_rpm_folder -type d -name '$item' | xargs -Ixxx rm -rf xxx";
    }
}

sub move_filtered_file{
    
    open my $info, $filter_list_file or die "Could not open $filter_list_file: $!";
    
    while( my $line = <$info>)  {
	chomp($line);
	
	$matched_file=`cd $csip_rpm_folder; file $line*`;
	$space_index = index($matched_file," ");
	$file_type = substr($matched_file, $space_index, length($matched_file));
	$file_name = substr($matched_file, 0 , $space_index-1);
	
	chomp($file_type);
	#print "the file type is |$file_type| \n ";
	#print "the file name is $file_name \n";
	
	if( $file_type eq " directory"){	
	    
	    print "cached a new directory:  $file_name \n";	
	    system("mv $csip_rpm_folder/$file_name $tailor_folder");
	}
	
	
    }
}
#--the majority of tailored files are large scale opensource package  
#&move_tailored_file


#--fileterd file include: GPL package, unmodified package 
#&move_filtered_file

#--extract all the tar archive in csip folder
#--remove src.rpm file in csip folder
#&extract_file


#--remove the picture and another file which are not going to be scanned
&remove_non_scan_file
