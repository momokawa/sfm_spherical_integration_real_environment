function laser_detection_dense()
% Rotate the equitangular image to make the normal vector of Laser Plane
% Z-diretion in spherical image
    img = imread("./images/laser_detection/laser_00000.jpg");
    R = R_laser_hori();
    [new_pos, original_pos] = convert_rotation(img, R);
    new_pos_int = round(new_pos);
    new_pos_int(new_pos_int==0) = 1;
    save mat/lookup_pos_laser_detection.mat new_pos_int original_pos
    img_rotaed = rotate_equi_laser_direction(new_pos_int, original_pos, img(:,:,2)); % green
end

function R_laser_detection = R_laser_hori()
    load calib_result/normal.mat
    normal_ = normal / norm(normal);
    Z = [0;0;1];
    C = cross(Z, normal_);
    theta = asin(norm(C));
    R_laser_detection = rotationVectorToMatrix(theta*C/norm(C));

    save mat/R_laser_detection.mat R_laser_detection
end

function  [new_points, d2] = convert_rotation(img, R)
    h = size(img,1);
    x = 1:size(img, 2);
    y = 1:size(img,1);
    X = repmat(x,1,size(img,1));
    Y = repmat(y,1,size(img,2));
    d2 = [X', Y'];
 
    ray = get_spherical_ray(d2, h);
    d2_new = (R*ray')';
    new_points = spherial2equi(d2_new, h);
end