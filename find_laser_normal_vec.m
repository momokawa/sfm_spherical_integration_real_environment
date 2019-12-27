function normal = find_laser_normal_vec()
    load calib_result/points_w.mat
    n_planes = length(points_w);
    
    % レーザ投光点の3次元座標から平面を決定
    U = [];
    for i = 1:n_planes
        U = [U; points_w{i}];
    end

    U(:, 4) = -1;

    % RANSACによる外れ値除去
    loop = 1000;
    thres = 0.005;
    ni = length(U);
    num = 1:ni;
    max_cnt = 0;
    for j = 1:loop
        samp = randperm(ni, 3);
        Uj = U(samp,:);        
        gj = solve_eq(Uj);
        error = abs(U * [gj 1]');
        in_idx = num(error<=thres);
        out_idx = num(error>thres);
        cnt = length(in_idx);
        if cnt >= max_cnt
            max_cnt = cnt;
            max_in_idx = in_idx;
            max_out_idx = out_idx;
        end
    end
    U_in = U(max_in_idx,:);
    U_out = U(max_out_idx,:);
    g = solve_eq(U_in);
    normal = g / norm(g)^2;

    if (1)
        figure(1000);
        scatter3(U_in(:,1),U_in(:,2),U_in(:,3), 'blue', '.');
        hold on;
        scatter3(U_out(:,1),U_out(:,2),U_out(:,3), 'red', 'x');
        axis equal;
        hold off;
    end
    
    save calib_result/normal.mat normal
end