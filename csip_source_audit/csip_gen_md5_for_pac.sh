#!/bin/bash

CSIP_Folder=/home/xji/mount_point/Source_Code_Audit/CSIP_Cert
Dist_folder=/home/xji/mount_point/Source_Code_Audit/CSIP_Dist

#Clean all the md5 summary stored
echo "" > "$Dist_folder/md5sum.txt"

if [ ! -d $Dist_folder ];
then
   echo "the dist folder is not existed, create one !!"
   mkdir -p $Dist_folder
fi

subdir_list=( "csip_folder" "csip_key_pacs" "server_src" "sop_src" )

for data in ${subdir_list[@]}
do
    echo "================"
    cd "$CSIP_Folder/$data"
    source_pacs=`ls -1`
    for data2 in ${source_pacs[@]}
    do
	
	distdir="$Dist_folder/$data"
	if [ ! -d $distdir ];
	then
	    echo "Create new folder $distdir"
	    mkdir -p "$distdir"
	fi
	#Get start to archive all the source as tar ball
	#tar -zcvf "$distdir/$data2.tar.gz" $data2
	
	#Generate md5 summarization and store them
	md5sum "$distdir/$data2.tar.gz" >> "$Dist_folder/md5sum.txt"
    done
done

#TODO: go through a folder and tar all the folder


