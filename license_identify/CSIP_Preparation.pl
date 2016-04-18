#!/usr/bin/perl
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Data::Dumper;
use Storable;

#added by jidiablo: those two line below is added for enabling the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

$csip_rpm_folder =  '/home/xji/mount_point/Source_Code_Audit/csip_rpm_folder';

$csip_rpm_list = '/home/xji/mount_point/Source_Code_Audit/rpm_list.txt';

$source_rpm_folder = '/home/xji/mount_point/Source_Code_Audit/src_rpm_folder';

$csip_folder = '/home/xji/mount_point/Source_Code_Audit/csip_folder';

$serialized_file = '/home/xji/mount_point/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';


sub go_through_rpm_list{
    my @rpmlist = `cat $csip_rpm_list`;

    my $retrieved_rpm_mapping = retrieve($serialized_file);
    open my $info, $csip_rpm_list or die "Could not open $csip_rpm_list: $!";
    
    while( my $line = <$info>)  {   
	chomp($line);
	#print "Line:: $line \n ";
	
	my $pure_name = &get_pure_rpm_name($line);
	my $result_file = &get_srcrpm_from_rpm($pure_name, $$retrieved_rpm_mapping);
	
	if($result_file eq ""){
	    print "Can not get result src.rpm !!! $line \n"
	}else{
	    #Todo: start to move the folder to the csip folder 
	    #print "Moving the folder to csip folder\n";
	    unless(-d $csip_folder){
		die "the csip scan space does not exist"
	    }

	    if(-d "$source_rpm_folder/$result_file"){
		print "start to copy $result_file \n";
		#Finally we copy the folder of src.rpm to csip_folder
		system "cp $source_rpm_folder/$result_file $csip_folder -raf"
	    }else{
		print "the folder $result_file does not exist !!\n";
	    }
	}
		
    }
}

sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;

    return $result_strs[0];
}

sub get_srcrpm_from_rpm{
    my $binary_rpm_pure_name = $_[0];
    my $rpm_map = $_[1];
    
    my $result_name = $rpm_map -> {$binary_rpm_pure_name};

    return $result_name;
}

&go_through_rpm_list
