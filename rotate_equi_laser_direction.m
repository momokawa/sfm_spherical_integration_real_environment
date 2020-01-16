function img_rotated = rotate_equi_laser_direction(new_pos_int, original_pos, img_green)
    % Convert image using look up table new_pos_int, original_pos [x,y]
    img_rotated = uint8(zeros(size(img_green)));
    n_p = size(img_green,1)*size(img_green,2);
    figure;
    imshow(img_green);
    for i = 1:n_p
        img_rotated(new_pos_int(i,2), new_pos_int(i,1)) = img_green(original_pos(i,2), original_pos(i,1));
    end
    figure;
    imshow(img_rotated);
end