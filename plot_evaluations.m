function plot_evaluations()
    % compare_with_true();
    plot_D_output_est();
end

function plot_D_output_est()
    files = dir("./csv/D_output");
    figure(1);
    hold on;
    
    for i = 1:length(files)
        if files(i).isdir ~= 1
            if files(i).name == ".keep"
                continue;
            end            
            f = [files(i).folder, '/', files(i).name];
            D = csvread(f);
            s = D(1,:);
            d = D(4,:);
            d(s<0) = [];
            s(s<0) = [];
            scatter(s,d, 'b');
        end
    end
    % xlim([610 620]);
    xlabel("s: Scales", 'FontSize', 15);
    ylabel("D(s) [mm]", 'FontSize', 15);
    ax = gca;
    ax.FontSize = 12;
    saveas(gcf, "./pics/plot_scales_est.jpg");
end

function plot_q_p()
% Plot Q(s) and P(s)
    
    
end