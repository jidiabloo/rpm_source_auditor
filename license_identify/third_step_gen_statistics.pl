#!/usr/bin/perl
use Encode;
use Spreadsheet::WriteExcel;
use Spreadsheet::ParseExcel;
use Data::Dumper;
use File::Basename;


#added by jidiablo: those two line below is added for enable the smartmatch
use v5.10.1;
no if $] >= 5.017011, warnings => 'experimental::smartmatch';


my $target_srcrpm_folder = '/home/xji/Source_Code_Audit/scanning_space';


my $oExcel = new Spreadsheet::ParseExcel;
#die "You must provide a filename to $0 to be parsed as an Excel file" unless @ARGV;

my %license_hash = {};


sub extract_license_info_from_excel(){
    #go through the target folder
    opendir my $dh, $target_srcrpm_folder or die "Can not open $dir_to_process: $!";    
    
    foreach $file(readdir $dh) {
	
	print "file: $file";
	$_ = $file;
	if(/\.rpm/ && -d "$target_srcrpm_folder/$file"){
	    print "one file in $target_srcrpm_folder is $file\n";
	    parse_license_info($target_srcrpm_folder, $file);
	}
    }
    closedir $dh;
}

sub parse_license_info(){
    my $rpm_folder = "$_[0]/$_[1]";
    
    chomp $rpm_folder;
    @rpm_folder_content = `ls $rpm_folder`;

    foreach (@rpm_folder_content){
	print(" iiiiii  : $_ \n");
	if(/\.xlt/){
	    print "cached an execl archive  $_\n";
	    my $execl_archive_path = "$rpm_folder/$_";
	    parse_col_num("$rpm_folder", $_);
	}
    }
}

sub parse_col_num(){
    my $rpm_foder_path = $_[0];
    my $excel_file_name = $_[1];
    
    my $rpm_file_name = basename($rpm_foder_path);
    
    my $excel_archive = "$rpm_foder_path/$excel_file_name";
    chomp $excel_archive;
    
    print("parsing file $excel_archive");

    my $oLicense = $oExcel->Parse($excel_archive);
    
    #print "FILE  :", $oLicense->{File} , "\n";
    #print "COUNT :", $oLicense->{SheetCount} , "\n";
    #print "AUTHOR:", $oLicense->{Author} , "\n" if defined $oLicense->{Author};

    #contains all the licenses in one source package
    my @license_list = ( );

    for(my $iSheet=0; $iSheet < $oLicense->{SheetCount} ; $iSheet++)
    {
	$oWkS = $oLicense->{Worksheet}[$iSheet];
	print "--------- SHEET:", $oWkS->{Name}, "\n";
	for(my $iR = $oWkS->{MinRow} ;
	    defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ;
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
			    print "doing push : ", $licence_info;
			    push(@license_list, $licence_info);
			}
		    }
		}
	    }
	}
    }
    print "Licenses List :: @license_list", "\n";
    #feed_result(@license_list, $rpm_file_name, $count);
    

    #put license information into a hash map
    $license_hash -> {$rpm_file_name} = "@license_list"; 
    
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


    
#print Dumper($license_hash);
my $row_num = 1;
while( my ($key, $value) = each $license_hash )
{
    $row_num ++;
    my $a_row_num="A".$row_num;
    my $b_row_num="B".$row_num;
    
    print "$a_row_num ::  $key => $value\n";
    $xlsContent->write( "A".$row_num, decode( 'utf8', $key ), $contentStyle2 );
    $xlsContent->write( "B".$row_num, decode( 'utf8', $value ), $contentStyle2 );
}

$xls->close();    
}


&extract_license_info_from_excel();

&feed_result;


