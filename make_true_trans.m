function make_true_trans()
    load_true_trans_img()
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