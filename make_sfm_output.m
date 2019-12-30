function make_sfm_output()
    % extract json and save mat format

    % create table to check the correspondance of S1.jpg and view #
    sfm_data_json = fileread('./openMVG_output/reconstruct/sfm_data.json');
    sfm_data = jsondecode(sfm_data_json);
    openMVG_extrinsics = sfm_data.extrinsics;
    save mat/openMVG_extrinsics.mat openMVG_extrinsics
    
    save_relation_viewid_filename(sfm_data.views);
    save_extrinsics(openMVG_extrinsics);
    openmvg2spherical_motion(); % Convert openmvg's motion estimation to spherical coordinate in 1st cam
    
end

function save_extrinsics(openMVG_extrinsics)
    load mat/view_list.mat
    num_view = length(view_list);
    num_valid = length(openMVG_extrinsics);
    valid_view = struct2array(rmfield(openMVG_extrinsics, 'value')); % use for gatting valid key(view) id
    
    sfm_est_T = zeros(4,4,num_valid);
    inv_sfm_est_T = zeros(4,4,num_valid); % inverse T
    unused = zeros(1, num_view-num_valid);
    cnt = 1;
    uncnt = 1;
    init_T = RotTrans2Tmatrix(openMVG_extrinsics(1).value.rotation, openMVG_extrinsics(1).value.center); % 1st cam T matrix
    
    for i = 1:num_view
        if i == 1 % TODO: What if view is invalid view by openMVG?
            sfm_est_T(:,:,cnt) = RotTrans2Tmatrix(eye(3), zeros(1,3));
            inv_sfm_est_T(:,:,cnt) = RotTrans2Tmatrix(eye(3), zeros(1,3));
            cnt = cnt + 1;
            
        elseif ismember(view_list(i,2), valid_view) % if the view is the view which was valid in the result of openMVG
            tmp_rot = openMVG_extrinsics(find(valid_view==view_list(i,2))).value.rotation;
            tmp_trans = openMVG_extrinsics(find(valid_view==view_list(i,2))).value.center;
            tmp_T = RotTrans2Tmatrix(tmp_rot, tmp_trans);
            
            sfm_est_T(:,:,cnt) = inv(init_T)*tmp_T;
            inv_sfm_est_T(:,:,cnt) = inv(sfm_est_T(:,:,cnt));
            %R = openMVG_extrinsics(find(valid_view==view_list(i,2))).value.rotation * (openMVG_extrinsics(1).value.rotation)'; % rotation matrix from view 1
            %sfm_est_T(1:3,1:3,cnt) = R;
            %inv_sfm_est_T(1:3, 1:3, cnt) = R';
            
            %t = openMVG_extrinsics(find(valid_view==view_list(i,2))).value.center - ...
            %       openMVG_extrinsics(find(valid_view==view_list(i,2))).value.rotation * (openMVG_extrinsics(1).value.rotation)' *openMVG_extrinsics(1).value.center; % translation from view 1
            %sfm_est_T(1:3,4,cnt) = t;
            %inv_sfm_est_T(1:3,4,cnt) = -1*R'*t;
            
            %sfm_est_T(4,4,cnt) = 1;
            %inv_sfm_est_T(4,4,cnt) = 1;
            cnt = cnt + 1;
        else % in case of unused view
            unused(uncnt) = view_list(i,2);
            uncnt = 1 + uncnt;
        end
    end
    save mat/unused.mat unused
    save mat/sfm_est_T.mat sfm_est_T
    save mat/inv_sfm_est_T.mat inv_sfm_est_T
end

function save_relation_viewid_filename(openMVG_views)
    % colum 1: image number S1, S2, S3... jpg
    % colum 2: view id in openMVG
    num_view = length(openMVG_views);
    view_list = ones(num_view,2);
    for i = 1:num_view
        view_list(i,2) = openMVG_views(i).key;
        view_list(i,1) = sscanf(openMVG_views(i).value.ptr_wrapper.data.filename, 'S%d.jpg');
    end
    view_list = sortrows(view_list,1);
    save mat/view_list.mat view_list
end

function T = RotTrans2Tmatrix(rot_matrix, trans_vec)
    T = zeros(4); % 4 x 4
    T(1:3,1:3) = rot_matrix'; % !!!! TRANSPOSE !!!! WHEN CONVERTINNG OPENMVG ROTATION MATRIX TO SPHERICAL COORDINATE
    T(1:3,4) = trans_vec;
    T(4,4) = 1;
end