function make_mask()
    % masks: 
    %   - 1) hide_left, hide_right: mask to seperate image from left_image and right_image
    %   - 2) device: mask to ignore devices
    load mat/setup.mat
    
    mask = struct( ...
        'device', [] ...
    );

    tmp = {'device'}; % file name for masks to be used    
    
    for i = 1:length(tmp)
        mpath = [setup.mask_dir, tmp{i}, '.png'];
        m = imread(mpath);
        if ndims(m) == 3
            m = rgb2gray(m);        
        end
        M = imbinarize(m);
        mask.(tmp{i}) = M;
    end
    
    save mat/mask.mat mask
end