#!/bin/bash
file1="sfm_openmvg.sh"
file2="openmvg_bin2json.sh"
file3="make_setup.m"

function change_dir_name () {
    echo "$1"
    cat "$1" | sed -e 's#home_dir\s*=\s*".*"#home_dir="'$2'"#g' > tmp | mv tmp "$1"
}
echo "New Directory Name : '$1'" \
&& change_dir_name $file1 $1 \
&& chmod +x $file1
&& change_dir_name $file2 $1 \
&& chmod +x $file2 \
&& change_dir_name $file3 $1