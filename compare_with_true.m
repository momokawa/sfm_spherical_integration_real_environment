function compare_with_true()
    true_pcd = csvread("./csv/integrated_cross_sections/true/all_true.csv");
    estimated_pcd = csvread("./csv/integrated_cross_sections/all_integrated_best_scale.csv");

    fs = 20; % フォントサイズ
    % maxErr = 150; % カラーバーの最大値
    maxErr = 380; % カラーバーの最大値
    % cm = gray;
    % cm = 1-cm;
    % cm = cm(5:end,:);
    cm = jet;
    csv = 1;
    
    C = true_pcd';
    E = estimated_pcd';

    dsize = length(C);
    step = 100;
    used = 1:step:dsize;
    C_ = C(:,used);
    E_ = E(:,used);
    %% Run ICP
    %[Ricp Ticp ER t] = icp(C, E, 15); % (standard settings)
    [Ricp Ticp ER t] = icp(C_, E_, 15, 'Matching', 'kDtree', 'Extrapolation', true); % (fast kDtree matching and extrapolation)

    % Transform data-matrix using ICP result
    Eicp = Ricp * E + repmat(Ticp, 1, length(E));

    %% plot
    figure(1);
    clf;

    %% ICP 前
    subplot(2, 2, 1);
    hf=plot3(C(3,:), C(2,:), -C(1,:), 'b.', E(3,:), E(2,:), -E(1,:), 'r.');
    set(hf, 'MarkerSize', 1);
    axis equal;

    set(gca, 'FontName', 'Times New Roman', 'FontSize', fs); 
    xlabel('Z [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    ylabel('X [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    zlabel('Y [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');

    title('Before ICP');

    %% ICP 後
    subplot(2, 2, 2);
    hf=plot3(C(3,:), C(2,:), -C(1,:), 'b.', Eicp(3,:), Eicp(2,:), -Eicp(1,:), 'r.');
    set(hf, 'MarkerSize', 1);
    axis equal;

    set(gca, 'FontName', 'Times New Roman', 'FontSize', fs); 
    xlabel('Z [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    ylabel('X [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    zlabel('Y [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');

    % title('After ICP');
    title('');

    %% RMS の変化
    subplot(2, 2, [3, 4]);
    plot(0:15, ER, '--x');

    set(gca, 'FontName', 'Times New Roman', 'FontSize', fs); 
    xlabel('iteration #', 'FontSize', fs, 'FontName', 'Times New Roman');
    ylabel('d_{RMS}', 'FontSize', fs, 'FontName', 'Times New Roman');

    legend('partial overlap');
    title(['Total elapsed time: ' num2str(t(end),2) ' s']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ここから誤差の評価
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    diff1 = (E' - C');
    err1 = sqrt(sum(diff1.*diff1, 2));

    diff2 = (Eicp' - C');
    err2 = sqrt(sum(diff2.*diff2, 2));
    disp(max(err2));
    %% 軸の目盛りの設定
    % maxErr = max([err1; err2]);

    dX = 2000;
    dY = 1000;
    dZ = 1000;

    figure();
    clf;


    %% ICP前の評価
    subplot(1,2,1);

    s = repmat(20, size(E,2), 1);
    ci = min(length(cm), max(1,ceil(length(cm)*err1/maxErr)));

    c = cm(ci',:);
    hf = scatter3(E(3,:), E(2,:), -E(1,:), s, c);
    hf.Marker = '.';

    set(gca, 'FontName', 'Times New Roman', 'FontSize', fs); 
    set(gca, 'xtick', dX*floor(min(E(3,:))/dX):dX:max(E(3,:)));
    set(gca, 'ytick', dY*floor(min(E(2,:))/dY):dY:max(E(2,:)));
    set(gca, 'ztick', dZ*floor(min(-E(1,:))/dZ):dZ:max(-E(1,:)));
    xlabel('Z [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    ylabel('X [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    zlabel('Y [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');

    title('Before ICP');

    axis equal;
    caxis([0 maxErr]);
    rotate3d on;

    % 色見本
    colormap(cm);
    hc = colorbar;
    ylabel(hc, 'Error [mm]');

    %% ICP後の評価
    subplot(1,2,2);

    s = repmat(20, size(Eicp,2), 1);
    ci = min(length(cm), max(1,ceil(length(cm)*err2/maxErr)));
    c = cm(ci',:);
    hf = scatter3(Eicp(3,:)', -Eicp(2,:)', Eicp(1,:)', s, c);
    hf.Marker = '.';

    set(gca, 'FontName', 'Times New Roman', 'FontSize', fs); 
    set(gca, 'xtick', dX*floor(min(Eicp(3,:))/dX):dX:max(Eicp(3,:)));
    set(gca, 'ytick', dY*floor(min(-Eicp(2,:))/dY):dY:max(-Eicp(2,:)));
    set(gca, 'ztick', dZ*floor(min(Eicp(1,:))/dZ):dZ:max(Eicp(1,:)));
    xlabel('Z [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    ylabel('X [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');
    zlabel('Y [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');

    % title('After ICP');
    title('');


    axis equal;
    caxis([0 maxErr]);

    rotate3d on;

    % 色見本
    colormap(cm);
    hc = colorbar;
    ylabel(hc, 'Error [mm]', 'FontSize', fs, 'FontName', 'Times New Roman');

    %% 結果の出力
    fprintf('==================================\n');
    fprintf('\t点群数　　　： %f [point]\n', length(C));
    fprintf('==================================\n');
    fprintf('[ICP前]\n');
    fprintf('\t誤差平均値　： %f [mm/point]\n', mean(err1));
    fprintf('\t誤差最小値　： %f [mm/point]\n', min(err1));
    fprintf('\t誤差最大値　： %f [mm/point]\n', max(err1));
    fprintf('\t誤差標準偏差： %f [mm/point]\n', std(err1));
    fprintf('==================================\n');
    fprintf('[ICP後]\n');
    fprintf('\t誤差平均値　： %f [mm/point]\n', mean(err2));
    fprintf('\t誤差最小値　： %f [mm/point]\n', min(err2));
    fprintf('\t誤差最大値　： %f [mm/point]\n', max(err2));
    fprintf('\t誤差標準偏差： %f [mm/point]\n', std(err2));
    fprintf('==================================\n');

    if csv==1
        csvwrite('./csv/compare/all_point_cloud_est_icp.csv', Eicp');
    end
end