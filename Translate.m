function res = Translate(img, delY, delX)

[R, C] = size(img); % 获取图像大小
res = zeros(R, C); % 构造结果矩阵。每个像素点默认初始化为0（黑色）
tras = [1 0 delX; 0 1 delY; 0 0 1]; % 平移的变换矩阵 

for i = 1 : R
    for j = 1 : C
        temp = [i; j; 1];
        temp = tras * temp; % 矩阵乘法
        x = temp(1, 1);
        y = temp(2, 1);
        % 变换后的位置判断是否越界
        if (x <= R) & (y <= C) & (x >= 1) & (y >= 1)
            res(x, y) = img(i, j);
        end
    end
end;