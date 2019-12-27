function ray_3d = get_spherical_ray(point_2d, h)
    % [u,v] = [x,y] 
    % point_2d = [x,y]
    
    r_x = sin(pi*point_2d(:,1)/h).*sin(pi*point_2d(:,2)/h);
    r_y = cos(pi*point_2d(:,1)/h).*sin(pi*point_2d(:,2)/h);
    r_z = cos(pi*point_2d(:,2)/h);
    

    ray_3d = [r_x, r_y, r_z];
end
