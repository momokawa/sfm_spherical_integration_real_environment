function calibrate_laser_plane_by_environment(img_laser, T, vert, hori, debug)
    % T: extrintic param from cam to plane
    % environement
    
    % Extract lasers on planes
    % 1. left side plane: x=0
    % 2. top plane: y=0
    % 3. right side plane: x=hori
    % 4. buttom plane: y=veri
    
    
    % corner' number
    % 1 ----> 2
    % |    x  |
    % ↓y      |
    % 4 ----- 3
    % 1: the origin of the coordinate
    disp('extract_extract_laser_points_on_planes()...');
    points_w = extract_laser_points_on_planes(img_laser, T, vert, hori,debug); % TODO need to set by hands
    disp('find_laser_normal_vec()....');
    n = find_laser_normal_vec();
end

function points_w = extract_laser_points_on_planes(img, T, vert, hori, debug)
    % Calibrate laser using 4 planes in the environments
    load mat/setup.mat
    img = img(:,:,setup.color_lsm);
    img(mask==0) = 0;
    img_size = size(img);
    RLCalc = getRLcalc(img_size); % Use different angle to detect which laser points are in which plane
    
    points_w = get_point_with_scale(img, T, vert, hori, debug,RLCalc);
    save calib_result/points_w.mat points_w
end

function points_w = get_point_with_scale(img, T, vert, hori, debug,RLCalc)
    %%%  Decide scale considering the points are in the each plane
    t = -(T(1:3,1:3))'*T(1:3,4); % inverse
    R = T(1:3,1:3)';
    points_2d = cell(1,4);
    points_w = cell(1,4); % laser 3d position with scale in plane coordinate
    
    for i=1:4 % As for 4 planes
       points_2d_laser = laser_extraction_line(img, RLCalc{i});
       if (debug)
           figure;
           imshow(img);
           hold on;
           scatter(points_2d_laser(:,1), points_2d_laser(:,2), 'green');
           P0 = [RLCalc{i}.CenterX, RLCalc{i}.CenterY];
           P1 = P0 + 500*[cos(pi/180*RLCalc{i}.Start), sin(pi/180*RLCalc{i}.Start)];
           P2 = P0 + 500*[cos(pi/180*RLCalc{i}.End), sin(pi/180*RLCalc{i}.End)];
           L1 = [P0; P1];
           L2 = [P0; P2];
           scatter(P0(1), P0(2), 'red', 'o','MarkerFaceColor','red');
           plot(L1(:,1), L1(:,2), 'red');
           plot(L2(:,1), L2(:,2), 'red');
           drawnow;
           hold off;
           pause(1);
           % close;
       end
       points_2d{i} = points_2d_laser;
       points_3d_ray = get_spherical_ray(points_2d_laser, size(img,1)); % 3d location in the plane coordinate
       
       % convert them to the plane coordinate system
       w_points = points_3d_ray*R';
       switch i
           case 1    % 1. left side plane: x=0
                s = -t(1)./ w_points(:,1); % Decide the scale
                points_w{i} = s .* points_3d_ray;
           case 2    % 2. top plane: y=0
                s = -t(2)./ w_points(:,2); % Decide the scale
                points_w{i} = s .* points_3d_ray;
           case 3    % 3. right side plane: x=hori
                s = (hori-t(1))./ w_points(:,1); % Decide the scale
                points_w{i} = s .* points_3d_ray;
           case 4    % 4. buttom plane: y=veri
                s = (vert-t(2))./ w_points(:,2); % Decide the scale
                points_w{i} = s .* points_3d_ray;
       end
    end
    
end
function RLCalc = getRLcalc(img_size)
    % TODO: by hand
    % 1. left side plane: x=0
    thred = 140;
    RLCalc_1 = struct(...
        'Start', 140, ... % サンプリング開始�?
        'End', 210, ... % サンプリング終�?�?
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'CenterX', img_size(2)/2, ... % サンプリング中�?点X座�?
        'CenterY',img_size(1)/2, ... % サンプリング中�?点Y座�?
        'Threshold', thred,... % 輝度値のしき�?値
        'PipeR', 300, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    );
    % 2. top plane: y=0

    RLCalc_2 = struct(...
        'Start', 218, ... % サンプリング開始�?
        'End', 320, ... % サンプリング終�?�?
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'CenterX', img_size(2)/2, ... % サンプリング中�?点X座�?
        'CenterY',img_size(1)/2, ... % サンプリング中�?点Y座�?
        'Threshold', thred,... % 輝度値のしき�?値
        'PipeR', 300, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    );

    % 3. right side plane: x=hori
    RLCalc_3 = struct(...
        'Start', 328, ... % サンプリング開始�?
        'End', 395, ... % サンプリング終�?�?
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'CenterX', img_size(2)/2, ... % サンプリング中�?点X座�?
        'CenterY',img_size(1)/2, ... % サンプリング中�?点Y座�?
        'Threshold', thred,... % 輝度値のしき�?値
        'PipeR', 300, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    ); 

    % 4. buttom plane: y=veri
    RLCalc_4 = struct(...
        'Start', 400, ... % サンプリング開始�?
        'End', 495, ... % サンプリング終�?�?
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'CenterX', img_size(2)/2, ... % サンプリング中�?点X座�?
        'CenterY',img_size(1)/2, ... % サンプリング中�?点Y座�?
        'Threshold', thred,... % 輝度値のしき�?値
        'PipeR', 300, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    ); 
    RLCalc = cell(1,4);
    RLCalc{1} = RLCalc_1;
    RLCalc{2} = RLCalc_2;
    RLCalc{3} = RLCalc_3;
    RLCalc{4} = RLCalc_4;
end

