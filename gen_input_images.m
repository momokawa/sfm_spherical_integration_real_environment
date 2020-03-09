function gen_input_images()
    % move_sfm_input();
    move_laser_extraction_input();
    move_nolaser_extraction_input();
end

function move_sfm_input()
    cnt = 0;
    imgs = dir('images/original/eqr_img/');
    
    for i = 1:length(imgs)
        if imgs(i).isdir==0 && contains(imgs(i).name, 'JPG')
            num = sscanf(imgs(i).name, 'R00%d_er.JPG');
            if rem(num,2) == 0 % even number's images are images for sfm
                input = [imgs(i).folder, '/', imgs(i).name];
                output = ['./images/sfm_input/S', num2str(cnt, '%05.f'), '.JPG'];
                command = sprintf("cp %s %s", input, output);
                system(command);
                cnt = cnt + 1;
            end
        end
    end
end

function move_laser_extraction_input()
% for laser extraction
    cnt = 0;
    imgs = dir('./images/original/eqr_img_90deg/');

    for i = 1:length(imgs)
        if imgs(i).isdir==0 && contains(imgs(i).name, 'JPG')
            num = sscanf(imgs(i).name, 'R00%d_er.JPG');
            if rem(num,2) ~= 0 % even number's images are images for sfm
                input = [imgs(i).folder, '/', imgs(i).name];
                output = ['./images/laser_detection/L', num2str(cnt, '%05.f'), '.JPG'];
                command = sprintf("cp %s %s", input, output);
                system(command);
                cnt = cnt + 1;
            end
        end
    end
end

function move_nolaser_extraction_input()
    % for laser extraction ; no laser image
    cnt = 0;
    imgs = dir('./images/original/eqr_img_90deg/');

    for i = 1:length(imgs)
        if imgs(i).isdir==0 && contains(imgs(i).name, 'JPG')
            num = sscanf(imgs(i).name, 'R00%d_er.JPG');
            if rem(num,2) == 0 % even number's images are images for sfm
                input = [imgs(i).folder, '/', imgs(i).name];
                output = ['./images/laser_detection/no_laser/N', num2str(cnt, '%05.f'), '.JPG'];
                command = sprintf("cp %s %s", input, output);
                system(command);
                cnt = cnt + 1;
            end
        end
    end
end