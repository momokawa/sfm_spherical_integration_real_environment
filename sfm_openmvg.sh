#!/bin/bash
home_dir="/home/momoko/Documents/research_programs/icpr2020/sfm_spherical_integration_real_environment/"
dataset="${home_dir}images/sfm_input/"
matches="${home_dir}openMVG_output/matches/"
reconstruct_dir="${home_dir}openMVG_output/reconstruct/"
init_image"env_00000.png"
secon_image="env_00001.png"
# If you want to use mask, put mask.png in the same folder
[ -d "${matches}" ] && echo "Directory exists" || mkdir -p "${matches}" \
&& [ -d "${reconstruct_dir}" ] && echo "Directory exists" || mkdir -p "${reconstruct_dir}" \
&& echo "##### main_SfMInit_ImageListing #####" \
&& openMVG_main_SfMInit_ImageListing -i $dataset -o $matches -c 7 -f 1 \
&& echo "##### openMVG_main_ComputeFeatures ####" \
&& openMVG_main_ComputeFeatures -i ${matches}sfm_data.json -o $matches -m AKAZE_FLOAT -p HIGH \
&& echo "#### openMVG_main_ComputeMatches ####" \
&& openMVG_main_ComputeMatches -i ${matches}sfm_data.json -o $matches -g a \
&& echo "#### openMVG_main_INcrementalfM ####" \
&& openMVG_main_IncrementalSfM -i ${matches}sfm_data.json -m $matches -o $reconstruct_dir
# -a ${init_image} -b ${secon_image}