function make_images()
    load mat/setup.mat
    
    img = struct( ...
        'n', [], ... % number of images
        'path', [] ... % dir path of images
    );
    img_nolaser = struct( ...
        'n', [], ...
        'path', [] ...
        );
    
    img_sfm_input = struct( ...
        'n', [], ...
        'path', [] ...  
        );
    

    [img, cnt] = save_img_path(setup.img_laser_dir, img);
    img.n = cnt;
    [img_nolaser, cnt] = save_img_path(setup.img_no_laser_dir, img_nolaser);
    img_nolaser.n = cnt;
    [img_sfm_input, cnt] = save_img_path(setup.sfm_input, img_sfm_input);
    img_sfm_input.n = cnt;
    
    setup.n = cnt; % the number of images
    
    save mat/img.mat img
    save mat/img_nolaser.mat img_nolaser
    save mat/img_sfm_input.mat img_sfm_input
    save mat/setup.mat setup
end

function [img_str, cnt] = save_img_path(dir_name, img_str)
    imgs = dir(dir_name);
    if isempty(imgs)
        error('cannot find the dir');
    end
    cnt = 0;
    
    for i = 1:length(imgs)
        if imgs(i).isdir==0 && contains(imgs(i).name, 'JPG') % To avoid to read mask.png files which are locate in same directory
            cnt = cnt + 1;
            img_str.path{cnt}=[dir_name, imgs(i).name];
        end
    end
end