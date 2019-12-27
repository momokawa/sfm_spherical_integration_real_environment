function make_laser_points_3d()
    load mat/setup.mat
    load calib_result/normal.mat
    load mat/laser.mat
    load mat/img.mat
    
    disp('Start 3d reconstruction of each cross-section...');
    h = setup.img_size(1);
    for i = 1:img.n
        fprintf("%dth\n", i);
        d3 = light_section_method(laser(i).d2, h, normal);
        laser(i).d3 = d3;
        num =  pad(num2str(i-1),5,'left','0');
        str  = sprintf('%scross_sections/d_%s.csv', setup.csv_dir, num);
        fprintf("Saving %s....\n", str);
        csvwrite(str, d3);
    end
    save mat/laser.mat laser
end