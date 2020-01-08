function s_p_0 = openmvg2spherical_points(openmvg_points, sfm_est_T_1st)
    % THIS FUNCTION MAKES POINTS IN OPENMVG COORDINATE TO
    % SPHERICAL COORDINATE BY REORDERING THE ORDER OF EACH ELEMENT OF
    % POINTS FROM 1ST CAM POSITION
    
    % sfm_est_T_1st: 1st cam's openmvg extrintic param
    R = -1*[1,0,0;0,0,1;0,1,0];
    T = [R,zeros(3,1);0,0,0,1]; % NOTICE: T' = T
    
    openmvg_points(:,4) = 1; % Homo
    
    % 1. Move to 1st cam coordi
    % 2. Change the order of xyz of points
    
    s_p_w = sfm_est_T_1st*openmvg_points'; % s_p_w: [4xnum]  spherical cooridinate points from world coordinate ( not yet from 1st cam position)
    s_p_0 = s_p_w'*T; % s_p_0 = sfm_est_T_1st*openmvg_points'; s_p_0 = s_p_0';
    
    s_p_0(:, 4) = []; 
end