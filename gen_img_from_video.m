function gen_img_from_video()
    input = './images/calibration_laser2cam/R0010590_er.MP4';
    output = './images/calibration_laser2cam/laser_on.jpg';
    
    gen_img_from_video_(input, output);

    input = './images/calibration_laser2cam/R0010591_er.MP4';
    output = './images/calibration_laser2cam/laser_off.jpg';
    
    gen_img_from_video_(input, output); 
end

function gen_img_from_video_(input, output)

    vdo = VideoReader(input);
    
    cnt = 1;
    while hasFrame(vdo)
        img = readFrame(vdo);
        cnt = 1 + cnt;
        if cnt > 50
            break;
        end
    end

    imwrite(img, output);
end