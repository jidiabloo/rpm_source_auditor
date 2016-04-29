#!/usr/bin/perl

use File::Remove 'remove';
use Archive::Extract;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Data::Dumper;
use Storable;

$key_pac_workspace="/home/xji/mount_point/Source_Code_Audit/key_package";
$sop_pac_workspace="/home/xji/mount_point/Source_Code_Audit/sop_src";
$server_pac_workspace="/home/xji/mount_point/Source_Code_Audit/server_src";

sub tailor_sop_content(){
     system("cd $sop_pac_workspace; find -name '.git' | xargs -I xxx rm -rf xxx");
}

sub tailor_key_pac(){
    system("cd $key_pac_workspace; find -name '.git' | xargs -I xxx rm -rf xxx");
}

sub tailor_server_pac(){
    ##TODO: remove all framework folder
    system("cd $server_pac_workspace; find -name 'framework' -type d | xargs -I xxx rm -rf xxx");
    
    ##TODO: remove all .git folder
    system("cd $server_pac_workspace; find -name '.git' | xargs -I xxx rm -rf xxx");
    
    ##TODO: remove hjz-web project
    system("cd $server_pac_workspace; rm -rf hjz-web");

    ##TODO: remove /eim-web/EimClient folder
    system("cd $server_pac_workspace/eim-web; rm -rf ./EimClient");
}

&tailor_server_pac
&tailor_key_pac
&tailor_sop_content
