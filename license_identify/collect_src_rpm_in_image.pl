#!/usr/bin/perl
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;

$serialized_file = '/home/xji/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';

$rpm_file_list = '/home/xji/Source_Code_Audit/rpm_list.txt';

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub get_pure_rpm_name{
    $rpm_file = $_[0];
    
    my $reg_exp = "\-[0-9].*\-[0-9]";
    
    my @result_strs = split /\-[0-9].*\-[0-9]/, $rpm_file;
    #print(" ---- $result_strs[0] \n");
    return $result_strs[0];
}


sub get_src_rpm_list_in_image{
    my $retrieved_rpm_mapping = retrieve($serialized_file);
    print Dumper($retrieved_rpm_mapping);
    

    my $count = keys $$retrieved_rpm_mapping;
    print"count : $count";

    open(SF, "$rpm_file_list") or die("Could not open rpm list file.");
    foreach $line(<SF>) {
	chomp($line);
	$_ = trim($line);
	
	my $pure_name = get_pure_rpm_name($_);
	
	my $result_file = &get_srcrpm_from_rpm($pure_name, $$retrieved_rpm_mapping);
	
	if($result_file ne ''){
	    #print "RRRRRR $result_file";
	} else {
	    print "Problem when handling: $pure_name \n";
	}	    
    }
}

sub get_srcrpm_from_rpm{
    my $binary_rpm_pure_name = $_[0];
    my $rpm_map = $_[1];    
    my $result_name = $rpm_map -> {$binary_rpm_pure_name};

    return $result_name;
}



&get_src_rpm_list_in_image
