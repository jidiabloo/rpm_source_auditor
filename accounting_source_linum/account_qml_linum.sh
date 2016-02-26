#!/bin/sh

function ergodic(){
    
    for file in ` ls $1 `
    do
	if [ -d $1"/"$file ]
	then
	    #echo "do find for $file"
	    LINUM_RESULT=`find $1"/"$file -name "*.qml" | xargs wc -l | grep "total"`
	    #echo $LINUM_RESULT
	    if [ "$LINUM_RESULT" != "" ]
	    then
		echo "$file : $LINUM_RESULT"  
	    fi
	    #wc -L $1"/"$file | cut -d' ' -f1 >> /home/xji/out
	else
	    echo "not a source directory"
	fi
    done
}


INIT_PATH="/home/xji/Source_Code_Audit/linum_scanning_space"
ergodic $INIT_PATH
