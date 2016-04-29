#!/usr/bin/perl
use Encode;
use Spreadsheet::WriteExcel;
use Spreadsheet::ParseExcel;
use File::Basename;

use File::Copy;
use Storable;
use Data::Dumper;

#added by jidiablo: those two line below is added for enable the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

my $oExcel = new Spreadsheet::ParseExcel;

#src.rpm from a image will be copied from this folder
$csip_folder = '/home/xji/mount_point/Source_Code_Audit/sop_src';

#License scanning will happend in this folder
$csip_archiving_folder = '/home/xji/mount_point/Source_Code_Audit/csip_sop_license_scan_space/';

#License scanner
$license_parser = '/home/xji/opt/ninka/ninka-excel.pl';

my %license_hash = {};

sub archive_sources{
    #TODO: go through all folder and compress them as tar.bz archive
    
    unless(-d $csip_folder){
	die "Cannot find directory '$csip_folder': $error";
    }
    
    #Go through the source folder
    opendir my $dh, $csip_folder or die "Can not open $csip_folder: $!";

    foreach $file(readdir $dh) {
	$_ = $file;
	
	next if $file eq ".";
	next if $file eq "..";
	
	print "$file \n";
	
	if(-d "$csip_folder/$_"){
	    #print "found a folder, start to archive it! \n";
	    
	    $tar_archive_name="$csip_archiving_folder/$_.tar.gz";
	    #print "cd $csip_folder; tar -zcvf $tar_archive_name $_ \n";
	    system "cd $csip_folder; tar -zcvf $tar_archive_name $_";
	    
	}
    }
    
    closedir $dh;
}

sub scan_license{
    my $file_to_process = $_[0];
    
    
    #print "Start to summarize the license info";
    @tar_files = `ls $csip_archiving_folder`;
    #print(" tar files : @tar_files \n");
    
    foreach (@tar_files){
	if(/\.tar\.gz/){
	    print "cached an source archive: $_ \n";
	    &do_generate_license_info($_);
	}
    }
}

#generate the license information in execl format
sub do_generate_license_info{
    chomp($target_archive = $_[0]);
    
    $target_excel_file = $target_archive.".xlt";
    
    if( -e $target_excel_file ){
	print("result xlt file is exist skip the scanning");
	return;
    }

    print("file $target_excel_file will be generated ! \n ");
    $scan_cmd = "$license_parser $target_archive $target_excel_file"; 
    print("cmd : $scan_cmd \n");
    system ("cd $csip_archiving_folder; $scan_cmd");
}


sub collect_license_summarization{
    my @xlt_files=`cd $csip_archiving_folder; find -name "*.xlt"`;
    

    my $file_name="";
    my $extension_index=0;
    foreach (@xlt_files){	
	print "cached an execl archive  $_\n";
	##TODO: start to get package name which will form a hash table
	$extension_index = rindex($_, ".src.rpm.tar.gz.xl");
	$source_pac_name = substr($_,0,$extension_index);

	my $execl_archive_path = "$csip_archiving_folder$_";
	parse_col_num("$execl_archive_path","$source_pac_name");
    }
}

sub parse_col_num(){
    
    my $excel_archive = $_[0];
    chomp $excel_archive;

    my $source_package_name = $_[1];
    chomp $source_package_name;
    
    print("parsing file $excel_archive\n");

    my $oLicense = $oExcel->Parse($excel_archive);
    
    #contains all the licenses in one source package
    my @license_list = ();

    for(my $iSheet=0; $iSheet < $oLicense->{SheetCount} ; $iSheet++)
    {
	$oWkS = $oLicense->{Worksheet}[$iSheet];
	print "--------- SHEET:", $oWkS->{Name}, "\n";
	for(my $iR = $oWkS->{MinRow} ;
	    defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow};
	    $iR++)
	{
	    for(my $iC = $oWkS->{MinCol} ;
		defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol} ;
		$iC++)
	    {
		$oWkC = $oWkS->{Cells}[$iR][$iC];
		#print "( $iR , $iC ) =>", $oWkC->Value, "\n" if($oWkC);
		my $licence_info = $oWkC->Value() if($oWkC);
		#print "License::  $licence_info \n ";
		if($iC == 3){
		    if ($licence_info eq "Licenses" || $licence_info eq "NONE" || $licence_info eq "Binary File" || $licence_info eq "UNKNOWN" || $licence_info eq "SeeFile"){
			#&feed_result($oWkC->Value);
		    }else{
			if ($licence_info ~~ @license_list){
			    #print "skip push : ";
			}else{
			    push(@license_list, $licence_info);
			}
		    }
		}
	    }
	}
    }
    print "##### Licenses List :: $source_package_name :: @license_list", "\n";

    #put license information into a hash map
    $license_hash -> {$source_package_name} = "@license_list"; 
    
}


sub feed_result{

### excel scalar start
my $xls = Spreadsheet::WriteExcel->new( "license.xls" );
my $xlsContent = $xls->add_worksheet( 'report' );

my $contentStyle = $xls->add_format();
$contentStyle->set_size( 11 );
$contentStyle->set_bold();
$contentStyle->set_align('center');
$contentStyle->set_text_wrap();
$contentStyle->set_color('black');

my $contentStyle2 = $xls->add_format();
$contentStyle2->set_size( 11 );
$contentStyle2->set_align('center');
$contentStyle2->set_text_wrap();
$contentStyle2->set_color('black');

$xlsContent->write( "A1", decode( 'utf8', "RPM Source Package Name" ), $contentStyle );
$xlsContent->write( "B1", decode( 'utf8', "License" ), $contentStyle );
### excel scalar end

my $row_num = 1;
while( my ($key, $value) = each $license_hash )
{
    print "******";
    $row_num ++;
    my $a_row_num="A".$row_num;
    my $b_row_num="B".$row_num;
    
    print "$a_row_num ::  $key => $value\n";
    $xlsContent->write( "A".$row_num, decode( 'utf8', $key ), $contentStyle2 );
    $xlsContent->write( "B".$row_num, decode( 'utf8', $value ), $contentStyle2 );
}

$xls->close();    
}

#--firstly need to compress all source folder to tar file
#&archive_sources

#--then start to genrate summarization of license information
#&scan_license

#--finally we start to put all summarization together
&collect_license_summarization
&feed_result
