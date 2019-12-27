function make_laser()
    load mat/setup.mat
    laser = struct(...
        'np', [], ... % the number of laser points which are for light-section method
        'd2', [], ... % 2d of laser points
        'd3', [] ... % 3d position of laser points
     );
    save mat/laser.mat laser
end