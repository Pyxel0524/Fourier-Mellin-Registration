function [indexPairs,matchmetric] = PointsCorr(im1,r1,c1,im2,r2,c2,winwidth,thre)
    % calculate the correlation between two images im1 and im2
    %         r      - Row coordinates of corner points.
    %         c      - Column coordinates of corner points.
    %     winwidth   - The size of correlation window. Can choose 10-30
    %       thre     - Threshold, according the paper, choose 0.6
    
    n = length(r1);
    num = []; des_m1 = []; des_m2 = [];
    Rm = size(im1,1);
    Cm = size(im1,2);
    
    for i = 1:n
        win1 = im1(max(r1(i)-winwidth/2,1):min(r1(i)+winwidth/2,Rm)-1,max(c1(i)-winwidth/2,1):min(c1(i)+winwidth/2,Cm)-1);
        win2 = im2(max(r2(i)-winwidth/2,1):min(r2(i)+winwidth/2,Rm)-1,max(c2(i)-winwidth/2,1):min(c2(i)+winwidth/2,Cm)-1);
        
        if (size(win1,1) ~= winwidth) | (size(win1,2) ~= winwidth)
            win1(winwidth,winwidth) = 0;
        end
        if (size(win2,1) ~= winwidth) | (size(win2,2) ~= winwidth)
            win2(winwidth,winwidth) = 0;
        end
        
        des_m1 = [des_m1; win1(:)'];
        des_m2 = [des_m2; win2(:)'];
              
    end
    
    [indexPairs,matchmetric] = matchFeatures(des_m1,des_m2,'MaxRatio',0.6,'MatchThreshold',(1-0.1*thre));
   

    
    
