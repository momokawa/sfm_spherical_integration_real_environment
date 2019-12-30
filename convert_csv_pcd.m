function convert_csv_pcd()
    sfm_csv = csvread("./ply/sfm_points_spherical_1stcam.csv");
    ptCloud = pointCloud(sfm_csv);
    pcwrite(ptCloud, "./ply/sfm_points_spherical_1stcam.pcd");
end