function point_3d = light_section_method(point_2d, h, normal)
    % point_2d: num_pint x 2
    ray = get_spherical_ray(point_2d, h); % num_point x 3 % since this is rotated ray vector
    rot_deg = [90, 0, 0]; % rot_x, rot_y, rot_z applied
    ray_orig = rotate_spherical_ray(ray, rot_deg); % rotate back
    s = repmat(norm(normal)^2, length(ray_orig),1) ./ diag(repmat(normal, length(point_2d), 1)*ray_orig');
    point_3d =  s .* ray_orig;
end