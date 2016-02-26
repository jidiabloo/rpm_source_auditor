#!/bin/bash


filelist=`find /home/xji/Source_Code_Audit/scanning_space -name *.tar.xz`

for file in $filelist
do 
 #echo $file
 base_name=`basename $file` 
 dir_name=`dirname $file`
 
 cd $dir_name
 rm *.xlt

 mkdir tmp
 cd tmp
 tar xvf ../$base_name
 cd ..
 tar -jcvf tmp.tar.bz2 ./tmp/*

 ~/opt/ninka/ninka-excel.pl tmp.tar.bz2 result.xlt
done

#cd $TARGET_SRCRPM_FOLDER
#mkdir tmp

#cd tmp




