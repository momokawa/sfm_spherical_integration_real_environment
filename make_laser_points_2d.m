function make_laser_points_2d()
    load mat/setup.mat
    load mat/img.mat
    load mat/img_nolaser.mat
    load mat/mask.mat
    load mat/laser.mat
    debug = 1;

    I_laser = imread(img.path{1});
    setup.img_size = [size(I_laser,1), size(I_laser,2)];
    save mat/setup.mat setup
    
    num_all = 0;
    disp('Start laser extraction...');
    for i = 1:img.n
        fprintf('%dth\n', i); 
        I_laser = imread(img.path{i});
        I_nolaser = imread(img_nolaser.path{i});
        M = get_diff_mask_img(I_laser, I_nolaser, 0); % Diff binary image
        disp(img.path{i});
        
        % points_d2 = make_laser_points_2d_single(I, M, debug, i);
        points_d2 = make_laser_points_2d_vertical_search(I_laser, M, debug, i);
        laser(i).d2 = points_d2; % ATTENTION: THIS d2 IS 90 deg ROTATED ONE!!!
        laser(i).np = size(points_d2, 1);
        num_all = num_all + laser(i).np;
    end
    setup.num_all = num_all;
    save mat/laser.mat laser
    save mat/setup.mat setup
end

function diff_mask = get_diff_mask_img(img_no_laser, img_with_laser, debug)
    % Generate mask image by difference image and half hidden image
    
    % Difference image
    diff_img = imabsdiff(img_no_laser, img_with_laser);
    diff_gray = rgb2gray(diff_img);
    
    diff_gray_bin = diff_gray>256/40; % binary image % TODO: You can change the threshhold
    % half hidden image
    half_mask = ones(size(img_no_laser,1),size(img_no_laser,2));
    
    img_size = size(half_mask);
    half_mask(1:img_size(1)/4,:) = 0;
    half_mask(img_size(1)*3/4:end,:) = 0;


    mask = logical(half_mask) .* diff_gray_bin;
    diff_mask = cast(mask, 'uint8');
    if (debug)
        figure;
        imshow(diff_mask);
        hold on;
        title('Mask');
        hold off;
    end
    
    save calib_result/mask.mat diff_mask
end