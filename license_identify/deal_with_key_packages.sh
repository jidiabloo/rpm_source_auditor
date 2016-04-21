#!/bin/bash

filelist=`cat ../file_list/key_pac_list`

workspace="/home/xji/mount_point/Source_Code_Audit/key_package"

for file in $filelist
do
    cd $workspace
    git clone ssh://xiang_ji_dev@gerrit.insyber.com:29418/"$file"
    cd $file
    git checkout -b xji_main remotes/origin/main_dev
done
