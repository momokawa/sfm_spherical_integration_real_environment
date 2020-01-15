function equi_d2 = spherial2equi(spherical_d3,h)
    % [x,y,z] n x 3 
    x = spherical_d3(:,1);
    y = spherical_d3(:,2);
    z = spherical_d3(:,3);
    
    v = (h/pi)*acos(z);
    u = (h/pi)*acos( y./ sqrt(1-z.^2) );
    equi_d2 = [u,v];
end