function make_true_integration()
    % INTEGRATE CROSS SECTIONS USING TRUE TRANS
    
    % Read cross sections
    
    % Integrate cross sections with the true trans
    % Save it to csv/cross_sections/true/
    load mat/T_10_deg.mat
    load mat/laser.mat
    load mat/img.mat
    
    all_integrated = [];
    
    T_0 = T_10_deg(:,:,1);
    T = eye(4,4);
    
    for i=1:img.n
        if i==1
            T = eye(4,4);
        else
            T = T_0*T;
        end
        d3 = (laser(i).d3)';
        d3(4,: ) = 1;
        univ_d3 = T*d3; % in the 1st cam's coordinate
        univ_d3(4,:) = [];
        univ_d3_ = univ_d3';
        num = pad(string(i-1), 5, 'left', '0');
        filename = sprintf("./csv/integrated_cross_sections/true/integrated_d3_%s.csv", num);
        csvwrite(filename, univ_d3_);
        all_integrated = [all_integrated; univ_d3_];
    end
    csvwrite("./csv/integrated_cross_sections/true/true_all_integrated.csv", all_integrated);
end
