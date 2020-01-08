function inv_sfm_est_T_spherical = openmvg2spherical_motion()
% Convert openmvg sfm estimate T matrix to spherical(left handed)
% coordinate
% inv_sfm_est_T_spherical should be same with true_T_spherical
    R = -1*[1,0,0;0,0,1;0,1,0];
    T = [R,zeros(3,1);0,0,0,1];
    
    load mat/inv_sfm_est_T.mat
    load mat/sfm_est_T.mat
    
    n = length(inv_sfm_est_T);
    
    inv_sfm_est_T_spherical = zeros(size(inv_sfm_est_T));
    sfm_est_T_spherical = zeros(size(inv_sfm_est_T));
    inv_sfm_est_T_spherical(:,:,1) = RotTrans2Tmatrix(eye(3), zeros(3,1));
    sfm_est_T_spherical(:,:,1) = RotTrans2Tmatrix(eye(3), zeros(3,1));
    
    for i=2:n
        inv_sfm_est_T_spherical(:,:,i) = T*inv_sfm_est_T(:,:,i)*T;
        % sfm_est_T_spherical(:,:,i) = inv(inv_sfm_est_T_spherical(:,:,i));
        sfm_est_T_spherical(:,:,i) = T*sfm_est_T(:,:,i)*T;
        % coz T is 正則 and sfm_est_T is also 正則
    end
    
    save mat/inv_sfm_est_T_spherical inv_sfm_est_T_spherical
    save mat/sfm_est_T_spherical sfm_est_T_spherical
end

function T = RotTrans2Tmatrix(rot_matrix, trans_vec)
    T = zeros(4); % 4 x 4
    T(1:3,1:3) = rot_matrix;
    T(1:3,4) = trans_vec;
    T(4,4) = 1;
end