function make_images()
    load mat/setup.mat
    
    img = struct( ...
        'n', [], ... % number of images
        'path', [] ... % dir path of images
    );
    imgs = dir(setup.img_laser_dir);
    if isempty(imgs)
        error('cannot find the dir');
    end
    cnt = 0;
    
    for i = 1:length(imgs)
        if imgs(i).isdir==0 && contains(imgs(i).name, 'jpg') % To avoid to read mask.png files which are locate in same directory
            cnt = cnt + 1;
            img.path{cnt}=[setup.img_laser_dir, imgs(i).name];
        end
    end
    img.n = cnt;
    setup.n = cnt; % the number of images
    
    save mat/img.mat img
    save mat/setup.mat setup
end