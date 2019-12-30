function get_spherical_openmvg_pcloud()
    fprintf("Changing openmvg sfm pcloud coordinate to spherical 1st cam coordinate....\n\n");
    file = './ply/cloud_and_poses_openmvg_original.ply';
    fprintf("Reading original openMVG sfm points file %s\n\n", file);

    original_mvgpcloud = pcread(file);
    fprintf("Converting point cloud coordinate to 1st cam in spherical coordinate....\n\n");
    sfm_points_spherical = openmvg2spherical_pcd(original_mvgpcloud); 
    
    fprintf("\n\nSaving point in mat/sfm_points_spherical.mat sfm_points_spherical, \n");
    savefilename = "./ply/sfm_points_spherical_1stcam.csv";
    fprintf("%s \n and ./ply/openMVG_points_only_on_1stcam.ply \n", savefilename);
    save mat/sfm_points_spherical.mat sfm_points_spherical
    csvwrite(savefilename,sfm_points_spherical);
    ptCloud = pointCloud(sfm_points_spherical);
    pcwrite(ptCloud, './ply/sfm_points_spherical_1stcam.ply');

    disp("Done.");
end

function  p_s_0 = openmvg2spherical_pcd(originalomvg)
    % Return openMVG points in spherical 1st cam based coordinate
    load mat/openMVG_extrinsics.mat
    mvgPoints = originalomvg.Location;
    camLocation = find(originalomvg.Color(:,1)==0);
    mvgPoints(camLocation, :) = []; % Exclude points of camera position
    
    % Convert location and orientation based on view 1
    sfm_est_T_1st = RotTrans2Tmatrix(openMVG_extrinsics(1).value.rotation, openMVG_extrinsics(1).value.center); % 1st cam T matrix    
    
    p_s_0 = openmvg2spherical_points(mvgPoints, sfm_est_T_1st);
end

function T = RotTrans2Tmatrix(rot_matrix, trans_vec)
    T = zeros(4); % 4 x 4
    T(1:3,1:3) = rot_matrix;
    T(1:3,4) = trans_vec;
    T(4,4) = 1;
end