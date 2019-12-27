function points_d2 = make_laser_points_2d_single(img, M, debug, i)
    load mat/setup.mat
    load mat/mask.mat
    load mat/laser.mat
    
    RLCalc = struct(...
        'Start', 0, ... % サンプリング開始�?
        'End', 359, ... % サンプリング終�?�?
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'CenterX', size(img,2)/2, ... % サンプリング中�?点X座�?
        'CenterY',size(img,1)/2, ... % サンプリング中�?点Y座�?
        'Threshold', 10,... % 輝度値のしき�?値
        'PipeR', 100, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    );
    save_img = 1;
    
    I = img(:,:,setup.color_lsm);
    I_ = I .* M;
    points_d2 = laser_extraction_line(I_, RLCalc); % [x,y]
    % Exlucde laser points in the other sphere of spherical camera, because it should not be originated from ring laser
    mask_corner = [setup.img_size(2)/2+1,1; ...
                    setup.img_size(2), 1; ...
                    setup.img_size(2), setup.img_size(2); ...
                    setup.img_size(2)/2+1, setup.img_size(2)/2+1];% [x,y]
    in = inpolygon(points_d2(:,1), points_d2(:,2), mask_corner(:,1), mask_corner(:,2)); % [x,y]
    points_d2 = points_d2(in, :);
    if (debug)
        imshow(I_);
        hold on;
        scatter(points_d2(:,1), points_d2(:,2), '.', 'green');
        P0 = [RLCalc.CenterX, RLCalc.CenterY];
        P1 = P0 + 500*[cos(pi/180*RLCalc.Start), sin(pi/180*RLCalc.Start)];
        P2 = P0 + 500*[cos(pi/180*RLCalc.End), sin(pi/180*RLCalc.End)];
        L1 = [P0; P1];
        L2 = [P0; P2];
        scatter(P0(1), P0(2), 'red', 'o','MarkerFaceColor','red');
        plot(L1(:,1), L1(:,2), 'red');
        plot(L2(:,1), L2(:,2), 'red');
        drawnow
        if (save_img) && i==1
            num = pad(num2str(i-1),5,'left','0');
            str  = sprintf('%sdetected_lasers/S%s.jpg', setup.img_laser_dir, num);
            saveas(gcf, str);
        end
        
        hold off
    end
end