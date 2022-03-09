function [registered1,registered2,Tx,Ty] = FourierMellin(Img1,Img2,fm1,fm2,lth,hth)

    % The procedure is as follows (note this does not compute scale)

    % (1)   read I1 
    % (2)   read I2 
    % (3)   FFT of I1, 频率移至0
    % (4)   FFT of I2, 频率移至0
    % (5)   对(3)高通滤波
    % (6)   对(4)高通滤波
    % (7)   把(5)换到对数坐标系
    % (8)   把(6)换到对数坐标系
    % (9)   FFT of (7)
    % (10)  FFT of (8)
    % (11)  相位相关 (9) 和 (10)
    % (12)  定位(11)相位相关峰值
    % (13)  计算旋转角 (360 / Image Y Size) * y from (12)
    % (14)  旋转图像 (13)角度
    % (15)  旋转图像 (13)角度+180
    % (16)  FFT of (14)
    % (17)  FFT of (15)
    % (18)  相位相关 (3) 和 (16)
    % (19)  相位相关 (3) 和 (17)
    % (20)  求(18)相位相关结果的峰值
    % (21)  求(19)相位相关结果的峰值
    % (22)  如果相位相关峰值(20) > 峰值(21), (20)得到的坐标是变换参数
    % (23a) 反之(21)结果作为变换参数
    % (23b) 如果旋转角 (13) < 180, 加180反之减去180

    % ---------------------------------------------------------------------
   
    
    
    % Load first feature map image (I1)

    I1 = fm1;

    
    

    % Load second image (I2)

    I2 = fm2;

    
    % ---------------------------------------------------------------------
   
    
    
    
    % Convert both to FFT, centering on zero frequency component
    
    SizeX = size(I1, 1);
    SizeY = size(I1, 2);
    
    FA = fftshift(fft2(I1));
    FB = fftshift(fft2(I2));
    
    % Output (FA, FB)
    
    
    
    
    % ---------------------------------------------------------------------
   
    
    
    
    % Convolve the magnitude of the FFT with a high pass filter)
    
    IA = hipass_filter(size(I1, 1),size(I1,2)).*abs(FA);  
    IB = hipass_filter(size(I2, 1),size(I2,2)).*abs(FB);  
        
    
    
        
    % Transform the high passed FFT phase to Log Polar space
    
    L1 = transformImage(IA, SizeX, SizeY, SizeX, SizeY, 'nearest', size(IA) / 2, 'full');
    L2 = transformImage(IB, SizeX, SizeY, SizeX, SizeY, 'nearest', size(IB) / 2, 'full');
        
    
        
    
    % Convert log polar magnitude spectrum to FFT
    
    THETA_F1 = fft2(L1);
    THETA_F2 = fft2(L2);
    
    
    
    
    % Compute cross power spectrum of F1 and F2
    
    a1 = angle(THETA_F1);
    a2 = angle(THETA_F2);

    THETA_CROSS = exp(i * (a1 - a2));
    THETA_PHASE = real(ifft2(THETA_CROSS));
    
  
    
    % Find the peak of the phase correlation

    THETA_SORTED = sort(THETA_PHASE(:));  % TODO speed-up, we surely don't need to sort
    
    SI = length(THETA_SORTED):-1:(length(THETA_SORTED));

    [THETA_X, THETA_Y] = find(THETA_PHASE == THETA_SORTED(SI));
    
    
    
    % Compute angle of rotation
    
    DPP = 360 / size(THETA_PHASE, 2);

    Theta = DPP * (THETA_Y - 1);
    
    % Output (Theta)
    
    
    
    
    
    % ---------------------------------------------------------------------
   
    
        
    
    % Rotate image back by theta and theta + 180
    
    R1 = imrotate(I2, -Theta, 'nearest', 'crop');  
    R2 = imrotate(I2,-(Theta + 180), 'nearest', 'crop');
    
    % Output (R1, R2)
    
    
    
    
	% ---------------------------------------------------------------------
   
     
    
    
    % Take FFT of R1
     
    R1_F2 = fftshift(fft2(R1));
     
     
     
    % Compute cross power spectrum of R1_F2 and F2
    
    a1 = angle(FA);
    a2 = angle(R1_F2);

    R1_F2_CROSS = exp(i * (a1 - a2));
    R1_F2_PHASE = real(ifft2(R1_F2_CROSS));
%     figure;
%     surf((R1_F2_PHASE - min(min(R1_F2_PHASE)))/(max(max(R1_F2_PHASE))-min(min(R1_F2_PHASE))));title('旋转互相关峰值图（梯度预处理后）');
%     
    % Output (R1_F2_PHASE)
     
     
    
    
    % ---------------------------------------------------------------------
   
     
    
    % Take FFT of R2
     
    R2_F2 = fftshift(fft2(R2));
     
     
     
    % Compute cross power spectrum of R2_F2 and F2
    
    a1 = angle(FA);
    a2 = angle(R2_F2);

    R2_F2_CROSS = exp(i * (a1 - a2));
    R2_F2_PHASE = real(ifft2(R2_F2_CROSS));

    % Output (R2_F2_PHASE)
    figure;
    surf((R2_F2_PHASE - min(min(R2_F2_PHASE)))/(max(max(R2_F2_PHASE))-min(min(R2_F2_PHASE))));title('平移互相关峰值图（梯度预处理后）');
    figure;
    
    % ---------------------------------------------------------------------
   
    
    
    
    % Decide whether to flip 180 or -180 depending on which was the closest

    MAX_R1_F2 = max(max(R1_F2_PHASE));
    MAX_R2_F2 = max(max(R2_F2_PHASE));
    
    if (MAX_R1_F2 > MAX_R2_F2)
        
        [y, x] = find(R1_F2_PHASE == max(max(R1_F2_PHASE)));
        
        R = imrotate(Img2, -Theta, 'nearest', 'crop');  
   
        
    else
        
        [y, x] = find(R2_F2_PHASE == max(max(R2_F2_PHASE)));
        
        if (Theta < 180)
            Theta = Theta + 180;
        else
            Theta = Theta - 180;
        end
        
        R = imrotate(Img2,-(Theta + 180), 'nearest', 'crop');
    end
    
    % Output (R, x, y)
    
    
    
    % ---------------------------------------------------------------------
   
    
    
    
    % Ensure correct translation by taking from correct edge
    
    Tx = x - 1;
    Ty = y - 1;
    
    if (x > (size(I1, 2) / 2))
        Tx = Tx - size(I1, 2);
    end
    
    if (y > (size(I1, 1) / 2))
        Ty = Ty - size(I1, 1);
    end
       
    % Output (Sx, Sy)
    
        

    
       
    % ---------------------------------------------------------------------   
    % FOLLOWING CODE TAKEN DIRECTLY FROM fm_gui_v2
    
    % Combine original and registered images
    
    input2_rectified = R; move_ht = Ty; move_wd = Tx;

    total_height = max(size(I1,1),(abs(move_ht)+size(input2_rectified,1)));
    total_width =  max(size(I1,2),(abs(move_wd)+size(input2_rectified,2)));
    combImage = zeros(total_height,total_width); registered1 = zeros(total_height,total_width); registered2 = zeros(total_height,total_width);

    % if move_ht and move_wd are both POSITIVE
    if((move_ht>=0)&&(move_wd>=0))
        registered1(1:size(I1,1),1:size(I1,2)) = Img1;
        registered2((1+move_ht):(move_ht+size(input2_rectified,1)),(1+move_wd):(move_wd+size(input2_rectified,2))) = input2_rectified; 
    elseif ((move_ht<0)&&(move_wd<0))   % if translations are both NEGATIVE
        registered2(1:size(input2_rectified,1),1:size(input2_rectified,2)) = input2_rectified;
        registered1((1+abs(move_ht)):(abs(move_ht)+size(I1,1)),(1+abs(move_wd)):(abs(move_wd)+size(I1,2))) = Img1;
    elseif ((move_ht>=0)&&(move_wd<0))
        registered2((move_ht+1):(move_ht+size(input2_rectified,1)),1:size(input2_rectified,2)) = input2_rectified;
        registered1(1:size(I1,1),(abs(move_wd)+1):(abs(move_wd)+size(I1,2))) = Img1;
    elseif ((move_ht<0)&&(move_wd>=0))
        registered1((abs(move_ht)+1):(abs(move_ht)+size(I1,1)),1:size(I1,2)) = Img1;
        registered2(1:size(input2_rectified,1),(move_wd+1):(move_wd+size(input2_rectified,2))) = input2_rectified;    
    end

    if sum(sum(registered1==0)) > sum(sum(registered2==0))   % find the image with the greater number of zeros - we shall plant that one and then bleed in the other for the combined image
        plant = registered1;    bleed = registered2;
    else
        plant = registered2;    bleed = registered1;
    end

    combImage = plant;
    for p=1:total_height
        for q=1:total_width
            if (combImage(p,q)==0)
                combImage(p,q) = bleed(p,q);
            end
        end
    end
        
    
    
    
    % Show final image
    
    imagesc(combImage, [lth hth]);
    colormap('gray');
    title('Fourier Mellin Registration (Pixel Level)')
    axis xy;