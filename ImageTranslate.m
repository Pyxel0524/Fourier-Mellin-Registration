function img2 = ImageTranslate(img1, delta_v, delta_h)%参数分别为图像矩阵、水平位移、垂直位移
    %%取位移的绝对值
    abs_delta_v = abs(delta_v);
    abs_delta_h = abs(delta_h);
    %%将图像uint8类型的数据转换为double类型的同时，把数据范围由原来的0~255映射到0~1，可以看作数据的一种归一化,以便计算
    img = im2double(img1);
    %获取图像的宽和高以及层数，即图像数据的行数r和列数c以及维数l
    [r,c,l] = size(img);
    
    %如果平移的水平位移或垂直位移大于图像的宽度或高度，则直接输出黑色图像即可
    if(abs_delta_h >= r || abs_delta_v >= c)
       img2 = zeros(r,c,l);
       return
    elseif(abs_delta_h == 0 && abs_delta_v == 0)%当水平和垂直位移都为0时，输出原图像
        img2 = img;
        return
    end
    
    %%构造矩阵
    rows = zeros(abs_delta_h,c,l);%用于插入图像的上方或下方，当垂直位移为负时插入图像的下方
    cols = zeros(r + abs_delta_h,abs_delta_v,l);%用于插入图像的左方或右方，当水平位移为负时插入图像的右方
    
    if(delta_v < 0)%当水平位移为负时插入图像的下方
        img = [img;rows];
        if(delta_h < 0)%当垂直位移为负时插入图像的右方
            img = [img,cols];
            img2 = img(abs_delta_h:end,abs_delta_v:end,:);%输出右下角
        elseif(delta_h >= 0)%当垂直位移为正时插入图像的左方
            img = [cols,img];
            img2 = img(max(abs_delta_h,1):end,1:c,:);%输出右下角
        end
    elseif(delta_v > 0)%当水平位移为正时插入图像的上方
        img = [rows;img];
        if(delta_h < 0)
            img = [img,cols];
            img2 = img(1:r,abs_delta_v:end,:);%输出右上角
        elseif(delta_h >= 0)
            img = [cols,img];
            img2 = img(1:r,1:c,:);%输出左上角
        end
    else%当水平位移为0时垂直方向不操作
        if(delta_h < 0)
            img = [img;rows];
            img2 = img(1:r,abs_delta_v:end,:);%输出图像右方
        elseif(delta_h >= 0)
            img = [cols,img];
            img2 = img(1:r,1:c,:);%输出图像左方
        end
    end
    
    [r2,c2,l2] = size(img2);
end