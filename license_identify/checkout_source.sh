#!/bin/bash

workspace="/home/xji/OSC_Workspace"
echo "start"
obs_projects=`ls /home/xji/OSC_Workspace`

echo @obs_projects


for file in $obs_projects
do
    cd "$workspace/$file"
    packages_with_service=`find -name "_service" | grep -v ".osc"`
    for pac in $packages_with_service
    do
	pac_name=`dirname $pac`
	echo "package name is $pac_name"
	cd "$workspace/$file/$pac_name"
	sed -i 's/syber_obs/xiang_ji_dev/' "$workspace/$file/$pac_name/_service"
	osc service run
	
    done

done
