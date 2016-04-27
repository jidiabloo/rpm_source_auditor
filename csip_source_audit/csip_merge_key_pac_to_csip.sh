#!/bin/bash

shopt -s extglob

csip_key_pac_path="/home/xji/mount_point/Source_Code_Audit/csip_key_pacs"


if [ -e "$csip_key_pac_path" ]
then
    echo "$csip_key_pac_path found."
else
    echo "$csip_key_pac_path not found, create one."
    mkdir -p $csip_key_pac_path
fi

key_pac_path="/home/xji/mount_point/Source_Code_Audit/key_package"
csip_pac_path="/home/xji/mount_point/Source_Code_Audit/csip_folder"

csip_pac_list=`cd $csip_pac_path; ls -1`

cd $key_pac_path
spec_list=`find -name "*.spec"`

for specf in $spec_list
do
    ##the steps below will fetch the package name in spec file
    pac_name=`grep "Name:" $specf`
    pure_name=${pac_name##*:}
    purename=`echo "${pure_name}" | sed -e 's/^[ \t]*//'`
    
    echo "$csip_pac_list" | grep $purename >/dev/null 2>&1
    
    if [ $? -eq 1 ];
    then
	echo "uncached package name: $purename"
	
	#Copy those package to new folder	
	echo "current spec file : $specf"
	spec_root=`echo "$specf" | cut -d "/" -f 2 | xargs -I xxx echo "./"xxx"/"`
	echo "current spec root : $spec_root"

	cp -raf $spec_root $csip_key_pac_path
	
    fi

    #cd $csip_pac_path
    #ls -1 | grep -n "$pure_name"
done
