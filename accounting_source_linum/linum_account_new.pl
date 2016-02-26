#!/usr/bin/perl
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;

#added by jidiablo: those two line below is added for enable the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

$binary_rpm_folder = '/home/xji/Source_Code_Audit/rpms';
$srcrpm_folder = '/home/xji/Source_Code_Audit/src_rpm';

$serialized_file = '/home/xji/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';
$linum_scan_space = '/home/xji/Source_Code_Audit/scan_space';

sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";
    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;
    print(" ---- $result_strs[0] \n");
    return $result_strs[0];
}


#The major data structure for containg the mapping information between the binary rpms and source rpms
#In this structure, the key is a name of binary rpm, and the value is the corresponding name from source rpm
%hash_paks = {};


#this function will do steps as below: 
#  1) Firstlly extract all the src.rpm file, save extracted content in a folder. 
#  2) Then parse the .spec file to get related package name of binary rpms
#  3) Save the mapping infromation between src.rpm and rpm file into a hash table and serialize it.
sub generate_hash_from_src_rpms{

    #system "mkdir -p $target_rpm_insight_folder";
    
    #go through the source folder
    opendir my $dh, $srcrpm_folder or die "Can not open $source_rpm_insight_folder: $!";

    foreach $file(readdir $dh) {
	$_ = $file;
	if(/\.src\.rpm/){
	    print "one file in $srcrpm_folder is $file \n";
	    my $rpm_file_path = "$srcrpm_folder/$file";
	    
	    move("$rpm_file_path","$rpm_file_path".".tmp");
	    system "mkdir -p $rpm_file_path";
	    move("$rpm_file_path".".tmp","$rpm_file_path/$file");

            #extract content in src.rpm file and save them into a folder
	    #&collect_files("$source_rpm_insight_folder/$file", $rpm_folder, $file );
	    
	    &extract_and_parse_srcrpm($file, $rpm_file_path);
	    
	    unlink "$rpm_file_path/$file";
	}
    }
    print Dumper($hash_paks);
    
    #Serialize the hash to a local file
    store \$hash_paks, $serialized_file;
    
    closedir $dh;
}

# use cpio command to extract a src.rpm file, then parse the spec file to get related information
sub extract_and_parse_srcrpm{
    print "AAAAAAAAAAAA 2\n";
    my $file_to_process = $_[0];
    my $rpm_folder = $_[1];

    print "extract the rpm file: $file_to_process  to:  $rpm_folder";    
    system "cd $rpm_folder ; rpm2cpio $file_to_process | cpio -idmv";
    @cpio_results = `ls $rpm_folder`;
    print(" cpio result : @cpio_results \n");
    
    foreach (@cpio_results){
	if(/\.spec$/){
	    print "cached an spec file: $_ \n";
	    #generate a hash which store the relationship between src.rpm and rpm file
	    &parse_spec_file($_, $rpm_folder);
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


#Parse the serialized hash table and find which src.rpm is correspondent to the rpm
sub get_srcrpm_from_rpm{
    my $binary_rpm_pure_name = $_[0];
    my $rpm_map = $_[1];
    
    my $result_name = $rpm_map -> {$binary_rpm_pure_name};

    if($result_name eq ""){
	#The 'pure name' is not truly pure, try the 'go around' solution. 
	#my $miner_index = rindex($binary_rpm_pure_name, "-");
	#my $refined_pure_name = substr($binary_rpm_pure_name, 0, $miner_index);
	#print "Exception: refined pure name: $refined_pure_name \n";
	#$result_name = $rpm_map -> {$refined_pure_name};
    }
    return $result_name;
}

sub get_src_rpm_by_rpm{
    my $retrieved_rpm_mapping = retrieve($serialized_file);
    print Dumper($retrieved_rpm_mapping);
    
    my $count = keys $$retrieved_rpm_mapping;
    print"count : $count";
    
    opendir my $dh, $binary_rpm_folder or die "Can not open $dir_to_process: $!";
    
    foreach $file(readdir $dh) {
	$_ = $file;
	if(/\.rpm/){
	    my $pure_name = get_pure_rpm_name($file);
	    print "get one rpm file name: $pure_name\n";
	    my $result_file = &get_srcrpm_from_rpm($pure_name, $$retrieved_rpm_mapping);
	    print "result file : $result_file\n";
	    
	    #print "Error: can not get correspondent src.rpm by $file";
	    die "can not get correspondent src.rpm by $file" unless $result_file ne '';

	    #current src.rpm has been exist in scan space
	    if(-d "$linum_scan_space/$result_file"){
		#do nothing here
		print "The file $result_file is existed in $linum_scan_space. Do nothing here\n";
	    }else{#move src.rpm folder to scan space and do scan_linum
		unless(-d "$srcrpm_folder/$result_file"){
		    die "Cannot find directory '$srcrpm_folder/$result_file': $error";
		}
		move("$srcrpm_folder/$result_file","$linum_scan_space/$result_file");
		&extract_source_code_from_archive("$linum_scan_space/$result_file", $result_file);
	    }
	    
	    #&collect_files("$source_srcrpm_folder/$result_file", "$target_linum_scan_folder/$result_file", $result_file );
		
	    
	}
    }
}

sub extract_source_code_from_archive{
    my $destniation_path = $_[0];
    
    #print "extract the rpm file: $file_to_process  to:  $destniation_path";    
    #system "cd $destniation_path ; rpm2cpio $file_to_process | cpio -idmv";
    @file_list = `ls $destniation_path`;
    print(" cpio result : @cpio_results \n");
    
    #Start to find the archive file and decompress it
    my $found_archive = 0;
    foreach (@file_list){
	print(" iiiiiiii  : $_ \n");
	if(/\.tar\.gz/ || /\.tar\.bz2/ || /\.xz/){
	    $found_archive = 1;
	    print "cached an source archive: $_ $destniation_path \n";
	    `cd $destniation_path; tar -xvf $_`;
	}
    }

    if($found_archive == 0){
	`echo Did not find any archive file to decompress for package $destniation_path !! >> audit_log`;
    }
    
    
}


sub do_scan_linum_routine{

    opendir my $dh, $linum_scan_space or die "Can not open $dir_to_process: $!";
    
    foreach $folder(readdir $dh) {

	$_ = $folder;
	if(/^\.+$/){
	    #do nothing
	}else{
	    #scan line number information for specific source folder
	    print(" start to scan line number for $linum_scan_space/$folder \n");
	    `cd $linum_scan_space/$folder; sloccount --details . > sloc_result `;
	    
	    my $cut_linum = `cd $linum_scan_space/$folder; grep -nx 'Computing results.' sloc_result | cut -d : -f 1`;
	    print "linum is : $cut_linum";
	    
	    `cd $linum_scan_space/$folder; sed -n '$cut_linum,$p' sloc_result > sloc_result`;
	}
	
	#my @src_files = `ls $folder`;
	#foreach (@src_files){
	#    if(/sloc_result/){
	#	
	#    }
	#}
	
    }
    
    #unless( -e "$destniation_path/sloc_result" ){
    #die "the sloc result file does not exists";
    #}

    #my $cut_linum = `cd $destniation_path; grep -nx "Computing results." txt | cut -d : -f 1`;

    #`cd $destniation_path; sed -n '$cut_linum,$p' sloc_result > sloc_result`;

    
#grep -nx "Computing results." txt | cut -d : -f 1
}

sub scan_file_size{
    
    #my $destniation_path = $_[0];

    
    #go through the source folder
    opendir my $dh, $linum_scan_space or die "Can not open $linum_scan_space: $!";
    
    foreach $file(readdir $dh) {
	$_ = $file;
	
	if(/^\.+$/){
	    #do nothing
	}else{	    
	    print "start to scan $file \n ";
	    `cd $linum_scan_space/$file; /home/xji/Shell_test/linum_account/size_test.sh`;
	    print "finished to scan $file \n ";
	}
    }



    #unless( -e "$destniation_path/sloc_result" ){
	#die "the sloc result file does not exists";
    #}

    #Todo: Read each line in sloc_result and add size information to each file
    #open(SF, "$destniation_path/sloc_result") or die("Could not open file.");
    #foreach $line(<SF>) {
#	chomp($line);	
    #}
    
    #Todo: Add Total size statistic information at the bottom of sloc_result

}

sub calculate_total_size{
    my $total_size=0;

    opendir my $dh, $linum_scan_space or die "Can not open $linum_scan_space: $!";
    foreach $file(readdir $dh) {
	$_ = $file;
	$total_size+=`cat total_size_statics | cut -d " " -f 4`;
	print "Total size is :: $total_size \n";
	
    }
    
}


#&generate_hash_from_src_rpms;
#&get_src_rpm_by_rpm;
#&do_scan_linum_routine;

&scan_file_size;
