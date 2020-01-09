function make_laser_points_2d()
    load mat/setup.mat
    load mat/img.mat
    load mat/mask.mat
    load mat/laser.mat
    debug = 1;

    % M = cast(mask(i).device, 'uint8');
    I = imread(img.path{1});
    setup.img_size = [size(I,1), size(I,2)];
    save mat/setup.mat setup
    
    num_all = 0;
    M = ones(setup.img_size);
    M = cast(M, 'uint8');
    disp('Start laser extraction...');
    for i = 1:img.n
        fprintf('%dth\n', i); 
        I = imread(img.path{i});
        disp(img.path{i});
        points_d2 = make_laser_points_2d_single(I, M, debug, i);
        laser(i).d2 = points_d2; 
        laser(i).np = size(points_d2, 1);
        num_all = num_all + laser(i).np;
    end
    setup.num_all = num_all;
    save mat/laser.mat laser
    save mat/setup.mat setup
end
