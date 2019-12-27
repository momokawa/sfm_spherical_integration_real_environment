function make_setup()
    setup = struct( ...
        'color_lsm', 2 ... % Color plane used for light-section method
    );
    save mat/setup.mat setup
end