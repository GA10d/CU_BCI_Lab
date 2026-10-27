function w = StereoASSR
    fs = 8000;
    f1 = 730; f2 = 1130;
    f1d = f1+40; f2d = f2+60;
    
    
    t = (0:fs*1-1)/fs;
    td = (0:fs*1-1)/fs;
    
    ind = [ones(1,240) zeros(1,180)];
    ind1 = ind(randperm(length(ind)));
    ind2 = ind(randperm(length(ind)));
    
    wc1 = sin(2*pi*f1*t);
    wd1 = sin(2*pi*f1d*td);
    wc2 = sin(2*pi*f2*t);
    wd2 = sin(2*pi*f2d*td);
    
    w1 = []; w2 = [];
    for cnt1 = 1:length(ind)
        if ind1(cnt1);  w1 = [w1 wc1]; end
        if ~ind1(cnt1); w1 = [w1 wd1];end
        if ind2(cnt1);  w2 = [w2 wc2]; end
        if ~ind2(cnt1); w2 = [w2 wd2];end
    end
    
    t = (1:length(w1))/fs;
    wa1 = sin(2*pi*40*t)+1.1;
    wa2 = sin(2*pi*35*t)+1.1;
    
    w1 = w1.*wa1;
    w2 = w2.*wa2;
    w = [w1;w2];
    % specgram(w(2,:));
    save('StereoASSR_sound.mat', 'w');