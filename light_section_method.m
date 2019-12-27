function point_3d = light_section_method(point_2d, h, normal)
    % point_2d: num_pint x 2
    ray = get_spherical_ray(point_2d, h); % num_point x 3
    
    s = repmat(norm(normal)^2, length(ray),1) ./ diag(repmat(normal, length(point_2d), 1)*ray');
    point_3d =  s .* ray;
end