function T_10_deg = make_true_trans()
    load_true_trans_img();
    T_0_true = calc_true_T();
    
    T_10_deg = zeros(4,4,2);
    for i=1:2
        T_10_deg(:,:,i) = T_0_true(:,:,i)*inv(T_0_true(:,:,i+1));
    end
    save mat/T_10_deg.mat T_10_deg
end

function load_true_trans_img()
    load mat/setup.mat
    
    panhead_calib_img = struct( ...
        'n', [], ... % number of images
        'path', [] ... % dir path of images
    );
    contents = dir(setup.panhead_calib_dir);
    
    if isempty(contents)
        error('cannot find the dir');
    end
    cnt = 0;
    
    for i = 1:length(contents)
        if contents(i).isdir==0 && contains(contents(i).name, 'jpg') % To avoid to read mask.png files which are locate in same directory
            cnt = cnt + 1;
            panhead_calib_img.path{cnt}=[setup.panhead_calib_dir , contents(i).name];
        end
    end
    panhead_calib_img.n = cnt;
    
    save mat/panhead_calib_img.mat panhead_calib_img
end

function T_0_true = calc_true_T()
    load mat/panhead_calib_img.mat
    
    %%%% Variables %%%%
    vert = 2140; % mm
    hori = 2075; % mm
    %%%%%%%%%%%%%%%%%%%
    
    T_0_true = zeros(4,4,panhead_calib_img.n);
    
    for i = 1:panhead_calib_img.n
        I = imread(panhead_calib_img.path{i});
        T = get_extrinsic_plane(I, vert, hori);
        T_0_true(:,:,i) = T;
    end
    
    save mat/T_0_true.mat T_0_true
end

%%%% FUNCTIONS TO GENERATE EXTRINSTIC PARAMETER FROM CAM TO THE PLANE %%%
function T = get_extrinsic_plane(img,vert,hori)
    % [R,t] = get_external_in_spherical_data(img); <- this was useless, can
    % use extrinsics function by matlab for spherical image
    
    is_check_corner = input('Did you finish the corner detection by hand?(y/n)','s');
    if is_check_corner ~= 'y'
        xyz = get_corner_spherical_location(img);
        save mat/true_xyz.mat xyz
    else
        load mat/true_xyz.mat
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
    save mat/true_XY.mat XY
    save mat/true_T.mat T 
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
    save mat/true_xyz.mat xyz
end