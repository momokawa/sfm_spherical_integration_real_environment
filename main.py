import run_openmvg	
import get_lightsection	
import find_scale_pointcloud
import matlab.engine
import sys

def main():	
    # After running move_and_take_data.py in Blender
    # python3 main.py &> log_$(date +"%m-%d-%Y").txt

    # Change home directory names
    new_home_dir="/home/momoko/Documents/research_programs/20191224_experiment/"
    command_str = "./change_home_dir_name.sh " + new_home_dir
    os.system(command_str)

    # OpenMVG
    os.system("./sfm_openmvg.sh")
    os.system("./openmvg_bin2json.sh")
	
    eng = matlab.engine.start_matlab()

    # calibration, extraction of laser, generation of true translation, and integration of cross sections with the true translation
    eng.main(nargout=0)

    eng.make_sfm_output(nargout=0) # Convert openMVG's pose into spherical thing
    eng.get_spherical_openmvg_pcloud(nargout=0) # Generate pcloud of openmvg based on 1st cam based spherical coordinate 
    print("Create mesh from sfm pcd with 1st view in CloudCompare, ./ply/sfm_points_spherical_1stcam.csv and save it as mesh_sfm_points_spherical_1stcam.ply. Are you done? (y/[n])")
    ans = input()
    if ans == 'y':
        eng.convert_csv_pcd(nargout=0)
        find_scale_pointcloud.main()
    else:
        sys.exit()

    # Compare with True pose of cameras
    eng.compare_with_true(nargout=0)

if __name__ == "__main__":	
    main()