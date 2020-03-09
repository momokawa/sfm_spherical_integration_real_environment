function points_d2 = make_laser_points_2d_vertical_search(img, M, debug, i)
    load mat/setup.mat
    RLCalc = struct(...
        'Step', 0.1, ... % サンプリングス�?�?プ�?
        'Threshold', 10,... % 輝度値のしき�?値
        'PipeR', 0, ...% サンプリングス�?�?プ開始距離?��中�?から周囲PipeRの�?囲は対象外�?
        'FilterSmoothingMode', 3,...
        'FilterSmoothingSize', 1, ...
        'ProjectionWidth', 5, ...
        'Height', [], ...
        'Width', [] ...
    );
    save_img = 0;
    
    I = img(:,:,setup.color_lsm);
    I_ = I .* M;
    imshow(I_);
    points_d2 = laser_extraction_vert(I_, RLCalc); % [x,y]
    % Exlucde laser points in the other sphere of spherical camera, because it should not be originated from ring laser
    % mask_corner = [setup.img_size(2)/2+1,1; ...
    %                setup.img_size(2), 1; ...
    %                setup.img_size(2), setup.img_size(2); ...
    %                 setup.img_size(2)/2+1, setup.img_size(2)/2+1];% [x,y]
    % in = inpolygon(points_d2(:,1), points_d2(:,2), mask_corner(:,1), mask_corner(:,2)); % [x,y]
    % points_d2 = points_d2(in, :);
    if (debug)
        imshow(I_);
        hold on;
        scatter(points_d2(:,1), points_d2(:,2), '.', 'green');
        drawnow
        if (save_img) && i==1
            num = pad(num2str(i-1),5,'left','0');
            str  = sprintf('%sdetected_lasers/S%s.jpg', setup.img_laser_dir, num);
            saveas(gcf, str);
        end
        
        hold off
    end
end

function points = laser_extraction_vert(img, RLCalc)
    img = cast(img, 'double');
    
%     RLCalc = struct(...
%         'Ang', 300, ...
%         'Threshold', 60,...
%         'FilterSmoothingMode', 3,...
%         'FilterSmoothingSize', 1, ...
%         'ProjectionWidth', 5, ...
%         'PipeR', 100, ...
%         'Height', [], ...
%         'Width', [] ...
%     );
    margin = 5;
    RLCalc.Height = size(img,1);
    RLCalc.Width = size(img,2);
 
    height = RLCalc.Height;
    width = RLCalc.Width;
    step = RLCalc.Step;
    pos = 1:step:width;
    pos = [pos', ones(size(pos))']; % [x,y]
    n = length(pos);

    imgvec = reshape(img',[],1);
    points = zeros(n,2);
    cnt = 0;
    for i = 1:n
        theta = pi*90/180; % search vertically
        pos_current = pos(i,:);
        px = lightSectionAng(pos_current, theta, imgvec, RLCalc);
        if px(1)~=0 && px(2)~=0
            cnt = cnt+1;
            points(cnt,:) = px;
        end
%         end
    end
end

function px = lightSectionAng(center, theta, img, RLCalc)
    cx = center(1);
    cy = center(2);
    height = RLCalc.Height;
    width = RLCalc.Width;
	smth = RLCalc.FilterSmoothingMode; % smoothing is on or not
	smthn = RLCalc.FilterSmoothingSize;
	thresh = RLCalc.Threshold;
    minR = RLCalc.PipeR;

    if smth == 1
        smthn = 0;
    else
        smthn = floor(smthn/2);
    end 
    
    
    cx = cx + minR * cos(theta);
    cy = cy + minR * sin(theta);
    
%     if smth >= 3
    if abs(tan(theta)) < 1
        tx = cos(theta)/abs(cos(theta)); 
        ty = sin(theta)/abs(cos(theta));
    else
        tx = cos(theta)/abs(sin(theta)); 
        ty = sin(theta)/abs(sin(theta));
    end
    nx = ty; ny = tx;

    proj = floor(RLCalc.ProjectionWidth / 2);

%     m = floor(min((width - cx)/tx, (height - cy)/ty));
    m = floor(min((width - cx)/abs(tx), (height - cy)/abs(ty)));
       
    line1 = -proj:proj;
    line2 = (1:m)';
    
    x = cx + repmat(tx*line2, [1,2*proj+1]) + repmat(nx*line1, [m,1]);
    y = cy + repmat(ty*line2, [1,2*proj+1]) + repmat(ny*line1, [m,1]);
    
    v_mat = (1 <= x) .* (x < width) .* (1 <= y) .* (y < height); %
    v_row = prod(v_mat, 2); % 
    x(~v_row,:) = [];
    y(~v_row,:) = [];
    
    if size(x,1) > 2*smthn+1      

        x0 = floor(x);
        y0 = floor(y);

        dx = x-x0;
        dy = y-y0;
        p = x0+(y0-1)*width;

        v00 = img(p);
        v01 = img(p+1);
        v10 = img(p+width);
        v11 = img(p+width+1);

        v = (v00.*(1-dx)+v01.*dx).*(1-dy)+(v10.*(1-dx)+v11.*dx).*dy;  
        w = sum(v,2)/(2*proj+1); % Take average

% visualize intensity of sampled points
%         plot(w);
%         drawnow
        
        % Smoothing
        sw = size(w);
        w2 = zeros(sw);
        pad = zeros(smthn, 1);
        w = [pad; w; pad];
        
        for i = 1:2*smthn+1
            w2 = w2 + w(i:sw(1)+i-1);
        end
        w2 = w2/(2*smthn+1); % final brightness

        [vmax, imax] = max(w2);
        if (vmax > thresh && imax ~= 1 && imax ~= size(w2,1))
            [valx, ~] = interpolate1D(w2(imax-1), w2(imax), w2(imax+1));
            r = (imax + valx-1) * sqrt(tx*tx + ty*ty);
            px = [r * cos(theta), r * sin(theta)]+[cx,cy];
        else
            px = [0 0];
        end
    else
        px = [0 0];
    end
end

% function v = biLinear(v00, v01, v10, v11, x, y)
% %     v0 = (v00 * (1 - x) + v01 * x);
% %     v1 = (v10 * (1 - x) + v11 * x);
%     v  =  (v00 * (1 - x) + v01 * x) * (1 - y) + (v10 * (1 - x) + v11 * x) * y;
%     v1 = [1-x, x] * [v00,v10;v01,v11] * [1-y, y]';
%     disp([v v1]);
% end

% Parabora fitting
function [valx,valmax] = interpolate1D(vm, v0, vp)
    den = 2.0 * v0  - vm - vp;
    if den~= 0
        valx  = (vp - vm) / (2.0 * den);
        valmax  = v0 + (vp - vm)*(vp - vm) / (8*den);
    else
        valx = 0; 
        valmax = 0; 
    end
end

% Gauss fitting
