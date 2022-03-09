clc;
clear all; 
close all;
%% Read Image (test algorithm)
I1 = double(imread('D:\Study\Master_project\code\image\optical_2_1.tif'));
I2 = imrotate(I1,0, 'nearest', 'crop');
I2 = ImageTranslate(I2,35,47);

%% Preprocess (Gradient graph) 
[Gx1,Gy1] = gradient(abs(I1)); G1 = sqrt(Gx1.^2 + Gy1.^2);
[Gx2,Gy2] = gradient(abs(I2)); G2 = sqrt(Gx2.^2 + Gy2.^2);

%% Mellin Registration 

[outputI1,outputI2,tx,ty] = FourierMellin(abs(I1),abs(I2),G1,G2,0,255);%显示范围自己调整

% surf(xcorr2(G1,G2));
% figure;surf(xcorr2(abs(I1),abs(I1)));
%% Show Translation Result

figure;imagesc(outputI1);colormap('gray');axis xy;
figure;imagesc(outputI2);colormap('gray');axis xy;

%% Insert
Ins_scale = 5; %缩放因子
I1_ins = imresize(outputI1,Ins_scale,'cubic');
I2_ins = imresize(outputI2,Ins_scale,'cubic');

%% Corner Detection

[cim1, r1, c1] = Harris(I1,2.5,0.04,'N', 50, 'display', true);% 选50个以上的特征点效果好，调参主要在Corner Detection这里调
[cim2, r2, c2] = Harris(I2,2.5,0.04,'N', 50, 'display', true);

[Index,Matric] = PointsCorr(I1_ins,r1,c1,I2_ins,r2,c2,200,0.97);


%% Least Square
C = [];

z = length(Index); % Index长度10以上匹配精度高
u = c1(Index(:,2)) - c2(Index(:,2)); u = medfilt1(u);
v = r1(Index(:,1)) - r2(Index(:,1)); v = medfilt1(v);

for j = 1:z
   C(j,:) = [1,c1(j),r1(j),c1(j).^2,r1(j).^2,c1(j).*r1(j)];
end
%
para_a = pinv(C'*C)*C'*u;
para_b = pinv(C'*C)*C'*v;


%% Subpixel Registration
%
delta_x = para_a(1) + para_a(2)*c1(Index(:,2)) + para_a(3)*r1(Index(:,1)) + para_a(4)*c1(Index(:,2)).^2 + para_a(5)*r1(Index(:,1)).^2 + para_a(6)*c1(Index(:,2)).*r1(Index(:,1)); 
delta_y = para_b(1) + para_b(2)*c1(Index(:,2)) + para_b(3)*r1(Index(:,1)) + para_b(4)*c1(Index(:,2)).^2 + para_b(5)*r1(Index(:,1)).^2 + para_b(6)*c1(Index(:,2)).*r1(Index(:,1)); 
%


avr_delta_x = round(mean(delta_x));
avr_delta_y = round(mean(delta_y));



% Combine original and registered images
    
input2_rectified = I2_ins; move_ht = avr_delta_y; move_wd = avr_delta_x ;

total_height = max(size(I1_ins,1),(abs(move_ht)+size(input2_rectified,1)));
total_width =  max(size(I1_ins,2),(abs(move_wd)+size(input2_rectified,2)));
combImage = zeros(total_height,total_width); registered1 = zeros(total_height,total_width); registered2 = zeros(total_height,total_width);

% if move_ht and move_wd are both POSITIVE
if((move_ht>=0)&&(move_wd>=0))
    registered1(1:size(I1_ins,1),1:size(I1_ins,2)) = I1_ins;
    registered2((1+move_ht):(move_ht+size(input2_rectified,1)),(1+move_wd):(move_wd+size(input2_rectified,2))) = input2_rectified; 
elseif ((move_ht<0)&&(move_wd<0))   % if translations are both NEGATIVE
    registered2(1:size(input2_rectified,1),1:size(input2_rectified,2)) = input2_rectified;
    registered1((1+abs(move_ht)):(abs(move_ht)+size(I1_ins,1)),(1+abs(move_wd)):(abs(move_wd)+size(I1_ins,2))) = I1_ins;
elseif ((move_ht>=0)&&(move_wd<0))
    registered2((move_ht+1):(move_ht+size(input2_rectified,1)),1:size(input2_rectified,2)) = input2_rectified;
    registered1(1:size(I1_ins,1),(abs(move_wd)+1):(abs(move_wd)+size(I1_ins,2))) = I1_ins;
elseif ((move_ht<0)&&(move_wd>=0))
    registered1((abs(move_ht)+1):(abs(move_ht)+size(I1_ins,1)),1:size(I1_ins,2)) = I1_ins;
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
figure;
imagesc(combImage);

colormap('gray');
title('Fourier Mellin Registration (Subpixel Level)')
axis xy;

Actual_horizontal = avr_delta_x/Ins_scale + tx;
Actual_vertical = avr_delta_y/Ins_scale + ty;


%% Subpixel Registration I1 and I2
figure;
imagesc(radar_a_axis * 180/pi,radar_r_axis,registered1, [0 hth]);
colormap('gray');
title('I1 after Translation')
axis xy;

figure;
imagesc(radar_a_axis * 180/pi,radar_r_axis,registered2, [0 hth]);
colormap('gray');
title('I2 after Translation')
axis xy;