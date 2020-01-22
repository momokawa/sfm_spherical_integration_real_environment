#!/bin/bash
file1="get_lightsection.py"
file2="move_and_take_data.py"
file3="move_and_take_data_with_lidar.py"
file4="move_and_take_data_perspective.py"
file5="sfm_openmvg.sh"
file6="sfm_openmvg_perspective.sh"
file7="openmvg_bin2json.sh"

function change_dir_name () {
    echo "$1"
    cat "$1" | sed -e 's#home_dir\s*=\s*".*"#home_dir="'$2'"#g' > tmp | mv tmp "$1"
}
echo "New Directory Name : '$1'" \
&& change_dir_name $file1 $1 \
&& change_dir_name $file2 $1 \
&& change_dir_name $file3 $1 \
&& change_dir_name $file4 $1 \
&& change_dir_name $file5 $1 \
&& change_dir_name $file6 $1 \
&& change_dir_name $file7 $1 \