#!/bin/bash
echo "openmvg_bin2json.sh..."
homedir=/home/momoko/Documents/research_programs/20191224_experiment/
input="${homedir}openMVG_output/reconstruct/sfm_data.bin"
output="${homedir}openMVG_output/reconstruct/sfm_data.json"
openMVG_main_ConvertSfM_DataFormat -i $input -o $output
echo "copying data to ply folder..."
cp "${homedir}openMVG_output/reconstruct/cloud_and_poses.ply" ./ply/cloud_and_poses_openmvg_original.ply

