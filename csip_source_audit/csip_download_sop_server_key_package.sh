#!/bin/bash

basepath=$(cd `dirname $0`; pwd)

key_pac_filelist=`cat ../file_list/key_pac_list`
key_pac_workspace="/home/xji/mount_point/Source_Code_Audit/key_package"

rm -rf "$key_pac_workspace/*"
for file in $key_pac_filelist
do
    cd $key_pac_workspace
    git clone ssh://xiang_ji_dev@gerrit.insyber.com:29418/"$file"
    cd $file
    git checkout -b xji_main remotes/origin/main_dev
done

cd $basepath 

sop_pac_filelist=`cat ../file_list/sop_pac_list`
sop_pac_workspace="/home/xji/mount_point/Source_Code_Audit/sop_src"

rm -rf "$sop_pac_workspace/*"
for file1 in $sop_pac_filelist
do
    cd $sop_pac_workspace
    git clone ssh://xiang_ji_dev@gerrit.insyber.com:29418/"$file1"
    cd $file1
    git checkout -b xji_main remotes/origin/main_dev
done

cd $basepath

server_pac_filelist=`cat ../file_list/server_pac_list`
server_pac_workspace="/home/xji/mount_point/Source_Code_Audit/server_src"

rm -rf "$server_pac_workspace/*"
for file2 in $server_pac_filelist
do
    cd $server_pac_workspace
    git clone ssh://xiang_ji_dev@gerrit.insyber.com:29418/"$file2"
    cd $file2
    git checkout -b xji_main remotes/origin/main_dev
done

