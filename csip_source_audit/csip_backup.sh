#!/bin/bash

shopt -s expand_aliases
. ~/.bashrc

backup_workspace="/home/xji/mount_point/CSIP_Backup"

project_list=( "syberos:/devel:/base/" "syberos:/devel:/nonbase/" "syberos:/devel:/qt/" "syberos:/devel:/mw/" "syberos:/devel:/soservice/" "syberos:/devel:/applications/" "syberos:/devel:/hw/" "syberos:/devel:/hw:/spreadtrum/" "syberos:/devel:/hw:/spreadtrum:/cactus/" )

for data in ${project_list[@]}
do  
    echo $wget_cmd${data}
    folder_name=${data//\:\//:}
    mkdir -p "$backup_workspace/$folder_name"
    cd "$backup_workspace/$folder_name"

    linkage="https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/"$data"standard_armv7tnhl/src/"
    

    echo "Start to download all the source rpm"
    wget --no-check-certificate -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm $linkage
        
    echo "Start to download the project cofnig and meta information"
    cmd_down_prjconf="osc meta prjconf $folder_name"
    cmd_down_meta="osc meta prj $folder_name"
    
    #cat ~/.bashrc | grep sdk

    mkdir prjconf_and_meta; cd prjconf_and_meta
    
    sdk $cmd_down_prjconf > projconf
    sdk $cmd_down_meta > meta
    
done

#TODO: Download repository of imagebuild
cd "$backup_workspace"
git clone ssh://xiang_ji_dev@gerrit.insyber.com:29418/imagebuild










