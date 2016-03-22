#!/usr/bin/perl
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;

#added by jidiablo: those two line below is added for enabling the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';


#$target_rpm_insight_folder = '/home/xji/Source_Code_Audit/rpm_insight_target';
#$source_rpm_insight_folder = '/home/xji/Source_Code_Audit/rpm_insight';

$source_rpm_insight_folder =  '/home/xji/mount_point/Source_Code_Audit/src_rpm';
$target_rpm_insight_folder = '/home/xji/mount_point/Source_Code_Audit/src_rpm_folder';

$serialized_file = '/home/xji/mount_point/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';

@obs_projects = ("applications", "security_app", "mw", "hw", "hw-spreadtrum", "hw-spreadtrum-orchid", "mer-override", "mer-override-nonqt", "skytree-core");


#The major data structure for containg the mapping information between the binary rpms and source rpms
#In this structure, the key is a name of binary rpm, and the value is the corresponding name from source rpm
%hash_paks = {};

sub go_through_src_rpms{
    #system "mkdir -p $target_rpm_insight_folder";
    
    unless(-d $target_rpm_insight_folder){
	die "Cannot create directory '$target_srcrpm_folder': $error";
    }
    
    #go through the source folder
    opendir my $dh, $source_rpm_insight_folder or die "Can not open $source_rpm_insight_folder: $!";
    foreach $file(readdir $dh) {
	$_ = $file;
	if(/\.src\.rpm/){
	    print "one file in $source_rpm_insight_folder is $file \n";
	    my $rpm_folder = "$target_rpm_insight_folder/$file";
	    #extract content in src.rpm file and save them into a folder
	    &collect_files("$source_rpm_insight_folder/$file", $rpm_folder, $file );
	    &extract_and_parse_srcrpm($file, $rpm_folder);
	}
    }
    print Dumper($hash_paks);
    
    #Serialize the hash to a local file
    store \$hash_paks, $serialized_file;
    
    closedir $dh;
}

sub collect_files{
    my $source_file = $_[0];
    my $rpm_folder = $_[1];
    my $file = $_[2];

    #create new folder containing rpm files and archive file
    system "mkdir -p $rpm_folder";
    
    print "copying file $source_file to $rpm_folder\n";
    copy($source_file, $rpm_folder) or die "File cannot be copied";
    
}

sub extract_and_parse_srcrpm{
    my $file_to_process = $_[0];
    my $rpm_folder = $_[1];

    print "extract the rpm file: $file_to_process  to:  $rpm_folder";    
    system "cd $rpm_folder ; rpm2cpio $file_to_process | cpio -idmv";
    @cpio_results = `ls $rpm_folder`;
    print(" cpio result : @cpio_results \n");
    
    foreach (@cpio_results){
	if(/\.spec/){
	    print "cached an spec file: $_ \n";
	    #generate a hash which store the relationship between src.rpm and rpm file
	    &parse_spec_file($_, $rpm_folder);
	}
    }
}

sub parse_spec_file{
    my $spec_file = $_[0];
    my $rpm_folder = $_[1];
    open(SF, "$rpm_folder/$spec_file") or die("Could not open file.");
    
    my $rpm_file_name = basename($rpm_folder);
    print "+++++ $rpm_file_name \n";

    my $pak_name;
        
    $count = 0;
    foreach $line(<SF>) {
	chomp($line);
	$_ = trim($line);
	#$_ = $line;

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
		#$hash_paks -> {$pak_name}  =  $pak_name;
		$hash_paks -> {$pak_name}  =  $rpm_file_name;
	    }else{
		print "Error: $_   :  index1 : $index1 : index2: $index2 : nameIndex :  $name_index";
	    }
	    
	}
	
	my $sub_pak;
	my $sub_pak_full_name;
	if(/\%package/){
	    if(/\%{name}/){
		my $find = "\%{name}";
		s/$find/$pak_name/g;
	    }

	    my $name_index = rindex($_," ");
	    $sub_pak = substr($_, $name_index+1);

	    if(/-n/){
		$sub_pak_full_name = $sub_pak;
	    }else{
		$sub_pak_full_name = $pak_name."-".$sub_pak;
	    }
	    print "gooooot package information:  $pak_name $sub_pak_full_name \n";
	    
	    $hash_paks -> {$sub_pak_full_name}  =  $rpm_file_name;
	    #$hash_paks -> {$sub_pak_full_name}  =  $pak_name;
	}
    }
        
    close(SF);
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub get_pure_rpm_name{
    my $reg_exp = "\-[0-9].*\-[0-9]";
    #my $version_index = index($str_test,"\-[0-9].*\-[0-9]");
    #my $result_str = substr($str_test, 0, $version_index);
    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $str_test;
    print(" ---- $result_strs[0] \n");
    return $result_strs[0];
}

# old fashion method for get pure name of rpm package
#sub get_pure_rpm_name{
#    $rpm_file = $_[0];
#    
#    $dot_index = index($rpm_file,".");
#    my $cuted_str = substr($rpm_file, 0, $dot_index);
#
#    my $miner_index = rindex($cuted_str, "-");
#    if($miner_index == -1){
#	$miner_index = index($str_test, "-");
#    }
#    
#    my $pure_str = substr($rpm_file, 0, $miner_index);
#    
#    #print(" ---- $pure_str \n");
#    return $pure_str;
#}
#

sub get_list_of_rpms_in_folder{
    my @dist_rpms = `ls $source_rpm_insight_folder`;
    my @pure_rpms = ();
    foreach (@dist_rpms){
	push(@pure_rpms, get_pure_rpm_name($_));
    }    
    return @pure_rpms;
}

sub prepare_rpms{
    #`ls $destniation_path`
    foreach my $prj_name (@obs_projects){
	my $folder = $source_rpm_insight_folder."/".$prj_name;
	my @pure_rpms = get_list_of_rpms_in_folder;
	
	my @rpms = `ls $folder`;
	foreach(@rpms){
	    my $pure_name = get_pure_rpm_name($_);
	    if($pure_name ~~ @pure_rpms){
		#skip the copy
	    }else{
		my $source_rpm_file = "$folder"."/"."$_";
		chomp($source_rpm_file);
		print "$source_rpm_file  >>>>>>  $source_rpm_insight_folder \n";

		copy($source_rpm_file, $source_rpm_insight_folder) or die "File cannot be copied";
	    }
	    #print ">>>>>> $pure_name \n";
	}
    }
}

sub get_srcrpm_from_rpm{
    my $retrieved_commit_list = retrieve('commit_list.lorui');
    print Dumper($retrieved_commit_list);
    
}

#&prepare_rpms;
&go_through_src_rpms;
