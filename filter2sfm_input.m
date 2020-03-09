function filter2sfm_input()
    load mat/setup.mat
    load mat/img_sfm_input.mat
    
    for i = 1:length(img_sfm_input.path)
        I = imread(img_sfm_input.path{i});
        noisyLAB = rgb2lab(I);
        roi = [210,24,52,41];
        patch = imcrop(noisyLAB,roi);
        patchSq = patch.^2;
        edist = sqrt(sum(patchSq,3));
        patchSigma = sqrt(var(edist(:)));
        DoS = 1.5*patchSigma;
        denoisedLAB = imnlmfilt(noisyLAB,'DegreeOfSmoothing',DoS);
        denoisedRGB = lab2rgb(denoisedLAB,'Out','uint8');
        imshow(denoisedRGB);
        num =  pad(num2str(i-1),5,'left','0');
        filename = sprintf('./images/sfm_input/denoised/Denoised%s.jpg', num);
        imwrite(denoisedRGB, filename);
    end
end