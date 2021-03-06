#!/usr/bin/perl
use File::Copy;
use Storable;
use Data::Dumper;

#added by jidiablo: those two line below is added for enable the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';


$source_binary_rpm_folder = '/home/xji/Source_Code_Audit/rpm_in_image';
$serialized_file = '/home/xji/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';
$target_linum_scan_folder = '/home/xji/Source_Code_Audit/linum_scanning_space';
$source_srcrpm_folder = '/home/xji/Source_Code_Audit/src_rpm';


sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";
    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;
    print(" ---- $result_strs[0] \n");
    return $result_strs[0];
}


sub go_through_binary_rpm_and_do_linum_scan{
    print "1111";
    my $retrieved_rpm_mapping = retrieve($serialized_file);
    print Dumper($retrieved_rpm_mapping);
    
    my $count = keys $$retrieved_rpm_mapping;
    print"count : $count";
    
    #go through the source folder
    opendir my $dh, $source_binary_rpm_folder or die "Can not open $dir_to_process: $!";
    foreach $file(readdir $dh) {
	$_ = $file;
	if(/\.rpm/){
	    my $pure_name = get_pure_rpm_name($file);
	    print "one file in $dir_to_process is $pure_name\n";
	    my $result_file = &get_srcrpm_from_rpm($pure_name, $$retrieved_rpm_mapping);
	    
	    if($result_file ne ''){
		&collect_files("$source_srcrpm_folder/$result_file", "$target_linum_scan_folder/$result_file", $result_file );
		&scan_linum("$target_linum_scan_folder/$result_file/$result_file", $result_file);
	    }
	}
    }
    closedir $dh;

}

sub scan_linum{
    my $file_to_process = $_[0];
    my $destniation_path = "$target_linum_scan_folder/$_[1]";

    print "extract the rpm file: $file_to_process  to:  $destniation_path";    
    system "cd $destniation_path ; rpm2cpio $file_to_process | cpio -idmv";
    @cpio_results = `ls $destniation_path`;
    print(" cpio result : @cpio_results \n");
    
    foreach (@cpio_results){
	print(" iiiiiiii  : $_ \n");
	if(/\.tar\.gz/ || /\.tar\.bz2/ || /\.xz/){
	    print "cached an source archive: $_ $destniation_path \n";
	    `cd $destniation_path; tar -xvf $_`;
	}
    }
}


sub collect_files{
    my $source_file = $_[0];
    my $target_file = $_[1];
    my $file = $_[2];

    #create new folder containing rpm files and archive file
    system "mkdir -p $target_file";
    
    print "copying file $source_file to $target_file\n";
    copy($source_file, $target_file) or die "File cannot be copied";
    
    return $result_file = "$target_file/$file";
}


sub get_srcrpm_from_rpm{
    my $binary_rpm_pure_name = $_[0];
    my $rpm_map = $_[1];
    
    my $result_name = $rpm_map -> {$binary_rpm_pure_name};

    if($result_name eq ""){
	#The 'pure name' is not truly pure, try the 'go around' solution. 
	my $miner_index = rindex($binary_rpm_pure_name, "-");
	my $refined_pure_name = substr($binary_rpm_pure_name, 0, $miner_index);
	print "Exception: refined pure name: $refined_pure_name \n";
	$result_name = $rpm_map -> {$refined_pure_name};
    }
    return $result_name;
}

#&go_through_binary_rpm_and_do_linum_scan;


$osc_workspace = '/home/xji/OSC_Workspace/Core:mipsel';
#specific requirement that scan all the source checked out by osc command
sub scan_linum_from_osc_workspace{
    #go through the source folder
    opendir my $dh, $osc_workspace or die "Can not open $osc_workspace: $!";

    foreach $file(readdir $dh) {
	$package_name = $file;
	print(" aaaaaaaa : $package_name \n");
	
	#system "cd $osc_workspace;";
	@file_list_in_package = `ls $osc_workspace/$package_name`;
	
	foreach (@file_list_in_package){
	    print(" iiiiiiii  : $osc_workspace/$package_name \n");
	    if(/\.tar\.gz/ || /\.tar\.bz2/ || /\.xz/){
		print "cached an source archive: $osc_workspace/$package_name/$_  \n";
		`cd $osc_workspace/$package_name; tar -xvf $_`;
	    }else{
		#print "cached an source archive: $_ $destniation_path \n";
	    }
	}
    }
}


#&scan_linum_from_osc_workspace;

