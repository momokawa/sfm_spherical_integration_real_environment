function calibrate_spherical_laser_plane()
    % images used for laser calibration
    imgname = './images/calibration_laser2cam/laser_on.jpg';
    fprintf("Reading image %s for laser plane calibration...\n", imgname);
    img_laser = imread(imgname);
    
    % laser off
    imgname = './images/calibration_laser2cam/laser_off.jpg';
    fprintf("Reading image %s for laser plane calibration...\n", imgname);
    img_laser_off = imread(imgname);
    %%%% Variables %%%%
    vert = 2140; % mm
    hori = 2075; % mm
    debug = 1;
    %%%%%%%%%%%%%%%%%%%
    mask = zeros(size(img_laser,1), size(img_laser,2));
    x_length = size(img_laser,2);
    mask(:, (1/4*x_length)+300:3/4*(x_length)) = 1;
    T = get_extrinsic_plane(img_laser_off,vert, hori);
    calibrate_laser_plane_by_environment(img_laser, mask, T, vert, hori, debug);  
end

function T = get_extrinsic_plane(img,vert,hori)
    % [R,t] = get_external_in_spherical_data(img); <- this was useless, can
    % use extrinsics function by matlab for spherical image
    
    is_check_corner = input('Did you finish the corner detection by hand?(y/n)','s');
    if is_check_corner ~= 'y'
        xyz = get_corner_spherical_location(img);
        save calib_result/xyz.mat xyz
    else
        load calib_result/xyz.mat
    end
    
    XY = [0,0; ... 
          hori,0; ...
          hori, vert; ...
          0, vert];

    A = cameraParameters;

    xy = [xyz(:,1)./xyz(:,3), xyz(:,2)./xyz(:,3)];
    [R,t] = extrinsics(xy, XY, A);

    % Check the result
    T = repmat(t', 1, 4);
    XY(:,3) = 0;
    XY_rep = (R'*XY' + T)';
    XY_rep_norm = zeros(4,3);
    for i=1:4
        tmp_norm = norm(XY_rep(i,:));
        XY_rep_norm(i,:) = XY_rep(i,:) / tmp_norm;
    end
    
    disp("light-ray of spherical image(xyz) and plane(XY)'s reprojection (XY_rep)");
    disp("xyz");
    disp(xyz);
    disp("XY_rep_norm");
    disp(XY_rep_norm);
    
    T = [R', t'; 0,0,0,1];
    save calib_result/XY.mat XY
    save calib_result/T.mat T 
end

function xyz = get_corner_spherical_location(img)
    img_ = rgb2gray(img);
    % points = detectKAZEFeatures(img_);
    width = 100;
    height = 100;
    height_img = size(img_,1);
    xy = zeros(4,2);

    % corner' number
    % 1 ---- 2
    % |      |
    % 4 ---- 3
    % 
    for i=1:4
        figure;
        imshow(img_);
        [x,y] = ginput(1);
        cropped_img = img_(y-height:y+height, x-width:x+width);
        figure;
        imshow(cropped_img);
        xy(i,:) = ginput(1)+[x-width, y-height];
        close all;
    end
    figure;
    imshow(img_);
    hold on;
    scatter(xy(:,1), xy(:,2),'red');
    pause(3);
    close all;
    xyz = get_spherical_ray(xy, height_img);
    save calib_result/xyz.mat xyz
end



