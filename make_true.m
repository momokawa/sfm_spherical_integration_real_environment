function make_true()
    % Generate true integration
    make_true_trans(); % Get T_0 matrix for 10 degree movement of panhead
    % Calculate the T for each cam's location by multipling T_0
    % T_i = (T_0)^i
    make_true_integration(); % TODO   
end