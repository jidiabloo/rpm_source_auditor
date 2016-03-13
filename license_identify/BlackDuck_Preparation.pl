#!/usr/bin/perl
use File::Copy;
use File::Basename;
use Data::Dumper;
use Storable;

#added by jidiablo: those two line below is added for enabling the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

$source_rpm_insight_folder =  '/home/xji/Source_Code_Audit/src_rpm';
$target_rpm_insight_folder = '/home/xji/Source_Code_Audit/src_rpm_folder';


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

    system "cd $rpm_folder ; rpm2cpio $source_file | cpio -idmv";
    @cpio_results = `ls $rpm_folder`;
    foreach (@cpio_results){
	if(/\.tar\.gz/ || /\.tar\.bz2/ ){
	    print "cached an source archive: $_ $destniation_path \n";
	    system "cd $rpm_folder ; tar -xvf $_";
	}
	if(/\.xz/){
	    system "cd $rpm_folder ; xz -d $_";

	    my $indx = rindex($_, ".xz" );
	    my $tar_file_name = substring($_, 0 ,indx);

	    unless(-e $tar_file_name){
		die "Cannot create tar file";
	    }
	    
	    system "cd $rpm_folder ; tar -xvf $tar_file_name";
    }
	    
	}
	
	
    }
    
    
}

&go_through_src_rpms
