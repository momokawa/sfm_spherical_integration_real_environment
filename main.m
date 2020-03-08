function main()
    gen_input_images(); % Move oritinal input images to the designed directory.
    make_setup();
    disp("Laser calibration...");
    calibrate_spherical_laser_plane();
    make_images();
    make_mask();
    make_laser();
    make_laser_points_2d();
    make_laser_points_3d();
    make_true(); % estimate true movement of 10 degree
end