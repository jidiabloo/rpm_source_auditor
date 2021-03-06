#!/usr/bin/perl
use File::Copy;
use Storable;
use Data::Dumper;

#added by jidiablo: those two line below is added for enable the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

$license_identify_cmd="./license_identify.pl";


$source_binary_rpm_folder = '/home/xji/Source_Code_Audit/rpm_in_image';
#$src_rpm_folder = '/home/xji/Source_Code_Audit/target_srcrpms';

#license scanning will happend in this folder
$target_srcrpm_folder = '/home/xji/Source_Code_Audit/scanning_space';

#src.rpm from a image will be copied from this folder 
$source_srcrpm_folder = '/home/xji/Source_Code_Audit/src_rpm';

$license_parser = '/home/xji/opt/ninka/ninka-excel.pl';
$serialized_file = '/home/xji/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';


@rpm_binary_project = ("applications-secrity","aplications", "hw-spreadtrum", "hw-spreadtrum-orchid", "kernel", "mw", "mer-override", "security-mer-override", "mer-override-secrity", "mer-override-nonqt", "mer-core");



#sub get_list_of_rpms_in_folder{
#    my @dist_rpms = `ls $source_binary_rpm_folder`;
#    my @pure_rpms = ();
#    foreach (@dist_rpms){
#	push(@pure_rpms, get_pure_rpm_name($_));
#    }    
#    return @pure_rpms;
#}
#


#sub prepare_rpm_binaries{
#    print "prepare !~!! @rpm_binary_project";
#    foreach my $prj_name (@rpm_binary_project){
#	my $folder = $source_binary_rpm_folder."/".$prj_name;
#	print "$folder \n";
#	my @pure_rpms = get_list_of_rpms_in_folder;
#	
#	my @rpms = `ls $folder`;
#	foreach(@rpms){
#	    my $pure_name = get_pure_rpm_name($_);
#	    if($pure_name ~~ @pure_rpms){
#		#skip the copy
#	    }else{
#		my $source_rpm_file = "$folder"."/"."$_";
#		chomp($source_rpm_file);
#		print "$source_rpm_file  >>>>>>  $source_binary_rpm_folder \n";
#		copy($source_rpm_file, $source_binary_rpm_folder) or die "File cannot be copied";
#	    }
#	}
#    }
#}
#

#sub do_license_scan {
#    #make dir containing .src.rpm if it is not exist
#    system "mkdir -p $target_srcrpm_folder";
#    unless(-d $target_srcrpm_folder){
#	die "Cannot create directory '$target_srcrpm_folder': $error";
#    }
#
#    #go through the source folder
#    opendir my $dh, $source_srcrpm_folder or die "Can not open $dir_to_process: $!";
#    foreach $file(readdir $dh) {
#	$_ = $file;
#	if(/\.rpm/){
#	    print "one file in $dir_to_process is $file\n";
#	    my $result_file = &collect_files("$source_srcrpm_folder/$file", "$target_srcrpm_folder/$file", $file );
#	    
#	    &scan_license($result_file, $file);
#	}
#    }
#    closedir $dh;
#}
#


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

sub scan_license{
    my $file_to_process = $_[0];
    my $destniation_path = "$target_srcrpm_folder/$_[1]";

    print "extract the rpm file: $file_to_process  to:  $destniation_path";    
    system "cd $destniation_path ; rpm2cpio $file_to_process | cpio -idmv";
    @cpio_results = `ls $destniation_path`;
    print(" cpio result : @cpio_results \n");
    
    foreach (@cpio_results){
	print(" iiiiiiii  : $_ \n");
	if(/\.tar\.gz/ || /\.tar\.bz2/ || /\.xz/){
	    print "cached an source archive: $_ $destniation_path \n";
	    &do_generate_license_info($_, $destniation_path);
	}
    }
}

#generate the license information in execl format
sub do_generate_license_info{
    chomp($target_archive = $_[0]);
    $folder_contain_archive = $_[1];
    $target_excel_file = $target_archive;
    if( -e $target_excel_file.".xlt" ){
	print("result xlt file is exist skip the scanning");
	return;
    }
    print("file $target_excel_file will be generated ! \n ");
    $scan_cmd = "$license_parser $target_archive $target_excel_file".".xlt"; 
    print("cmd : $scan_cmd \n");
    system ("cd $folder_contain_archive; $scan_cmd");
}

sub get_pure_rpm_name{
    my $reg_exp = "\-[0-9].*\-[0-9]";
    #my $version_index = index($str_test,"\-[0-9].*\-[0-9]");
    #my $result_str = substr($str_test, 0, $version_index);
    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $str_test;
    print(" ---- $result_strs[0] \n");
    return $result_strs[0];
}

#sub get_pure_rpm_name{
#    $rpm_file = $_[0];
#    
#    $dot_index = index($rpm_file,".");
#    my $cuted_str = substr($rpm_file, 0, $dot_index);
#
#    my $miner_index = rindex($cuted_str, "-");
#    if($miner_index == -1){
#	$miner_index = index($rpm_file, "-");
#    }
#    
#    my $pure_str = substr($rpm_file, 0, $miner_index);
#    
#    #print(" ---- $pure_str \n");
#    return $pure_str;
#}
#



sub go_through_binary_rpm_and_do_license_scan{

    my $retrieved_rpm_mapping = retrieve($serialized_file);
    #print Dumper($retrieved_rpm_mapping);
    
    my $count = keys $$retrieved_rpm_mapping;
    print"count : $count";


    #make dir containing .src.rpm if it is not exist
    #system "mkdir -p $source_binary_rpm_folder";
    
    #check if the binary rpm folder is exist
    unless(-d $source_binary_rpm_folder){
	die "Cannot create directory '$source_binary_rpm_folder': $error";
    }

    #go through the source folder
    opendir my $dh, $source_binary_rpm_folder or die "Can not open $dir_to_process: $!";
    foreach $file(readdir $dh) {
	$_ = $file;
	print "one file in is $_\n";
	if(/\.rpm/){
	    
	    my $pure_name = get_pure_rpm_name($file);
	    
	    my $result_file = &get_srcrpm_from_rpm($pure_name, $$retrieved_rpm_mapping);
	    
	    if($result_file ne ''){
		&collect_files("$source_srcrpm_folder/$result_file", "$target_srcrpm_folder/$result_file", $result_file );
		&scan_license("$target_srcrpm_folder/$result_file/$result_file", $result_file);
	    }

	    print "RRRRRRRRRRRR : $result_file \n ";
	    #&scan_license($result_file, $file);
	}
    }
    closedir $dh;
}


sub get_srcrpm_from_rpm{
    my $binary_rpm_pure_name = $_[0];
    my $rpm_map = $_[1];
    
    my $result_name = $rpm_map -> {$binary_rpm_pure_name};

#    if($result_name eq ""){
#	#The 'pure name' is not truly pure, try the 'go around' solution. 
#	my $miner_index = rindex($binary_rpm_pure_name, "-");
#	my $refined_pure_name = substr($binary_rpm_pure_name, 0, $miner_index);
#	print "Exception: refined pure name: $refined_pure_name \n";
#	$result_name = $rpm_map -> {$refined_pure_name};
#    }
#
    return $result_name;
}


#&prepare_rpm_binaries;
&go_through_binary_rpm_and_do_license_scan;
#&do_license_scan;
