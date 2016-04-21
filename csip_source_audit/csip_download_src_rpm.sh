#!/bin/bash

cd /home/xji/mount_point/Source_Code_Audit/src_rpm

rm -rf *

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/base/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/nonbase/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/qt/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/mw/standard_armv7tnhl/src/


wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/soservice/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/applications/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/hw/standard_armv7tnhl/src/

wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/hw:/spreadtrum/standard_armv7tnhl/src/


wget --no-check-certificate  --user=xiang_ji_dev --password=syberos  -P. --mirror --no-parent -r -N -nH -l inf --cut-dirs=4 -A src.rpm https://xiang_ji_dev:el%26%5f67kU6@repo2.insyber.com/syberos:/devel:/hw:/spreadtrum:/cactus/standard_armv7tnhl/src/

find -name "*.src.rpm" | xargs -Ixxx mv xxx .

empty_folders=`find -type d`

if [[ x$empty_folders != x"." ]]; then rm -rf $empty_folders; fi
