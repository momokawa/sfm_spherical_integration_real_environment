function eval_plane()
    estimated_pcd = csvread("./csv/integrated_cross_sections/all_integrated_best_scale.csv");
    pcshow(estimated_pcd);
    % 1) Select points which are on plane
    % 2) Move the cursor on the points, and right click
    % 3) Select "Create variable" and save as p_floor, p_ceil, p_long_wall,
    % p_short_wall
    yesno = input("did you save points before? (y/n)", "s");
    if yesno~="y"
        yesno = input("select points by hands....Done?(y/n)", "s");
        if yesno=="y"
           save_points(p_wall_1, "p_wall_1");
           save_points(p_wall_2, "p_wall_2");     
        end
    end
    
    p_floor = csvread("./evaluation/p_floor.csv");
    p_ceil = csvread("./evaluation/p_ceil.csv");
    p_wall_1 = csvread("./evaluation/p_wall_1.csv");
    p_wall_2 = csvread("./evaluation/p_wall_2.csv");
    evaluate_flatness(p_wall_1, "p_wall_1");
    evaluate_flatness(p_wall_2, "p_wall_2");
    evaluate_flatness(p_floor, "p_floor");
    evaluate_flatness(p_ceil, "p_ceil");
end

function save_points(p_flat, flat_name)
    str = sprintf("./evaluation/%s.csv", flat_name);
    csvwrite(str, p_flat);
end
function evaluate_flatness(p_flat, flat_name)
    flat_pcd = pointCloud(p_flat);
    maxdist = 1000;
    [model, inliderIndices, outlierIndices, meanError] = pcfitplane(flat_pcd, maxdist);
    str = sprintf("./evaluation/flatness_eval_%s.mat", flat_name);
    save(str, 'model', 'inliderIndices', 'outlierIndices', 'meanError');
end