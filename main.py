import run_openmvg	
import get_lightsection	
import find_scale_pointcloud
import matlab.engine
import sys

def main():	
    # After running move_and_take_data.py in Blender

    # OpenMVG
    os.system("./sfm_openmvg.sh")
    os.system("./openmvg_bin2json.sh")
	
    eng = matlab.engine.start_matlab()

    # calibration, extraction of laser, generation of true translation
    eng.main(nargout=0)

    eng.make_sfm_output(nargout=0) # TODO
    eng.get_spherical_openmvg_pcloud(nargout=0) # Generate pcloud of openmvg 1st cam based spherical coordinate # TODO
    print("Create mesh from sfm pcd with 1st view, ./ply/sfm_points_spherical_1stcam.csv and save it as mesh_sfm_points_spherical_1stcam.ply. Are you done? (y/[n])")
    ans = input()
    if ans == 'y':
        eng.convert_csv_pcd(nargout=0) # TODO
        find_scale_pointcloud.main() # TODO
    else:
        sys.exit()

    # Get true integration
    # eng.integrate_true_trans(nargout=0)

if __name__ == "__main__":	
    main()