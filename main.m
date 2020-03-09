function main()
    filter2sfm_input();
    gen_input_images(); % Move oritinal input images to the designed directory.
    make_setup();
    gen_img_from_video();
    disp("Laser calibration...");
    calibrate_spherical_laser_plane();
    make_images();
    make_mask();
    make_laser();
    make_laser_points_2d(); % detect laser vertically
    make_laser_points_3d(); % rotate back => 3d recostruction
    make_true(); % estimate true movement of 10 degree
end