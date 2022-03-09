function res = Translate(img, delY, delX)

[R, C] = size(img); % ��ȡͼ���С
res = zeros(R, C); % ����������ÿ�����ص�Ĭ�ϳ�ʼ��Ϊ0����ɫ��
tras = [1 0 delX; 0 1 delY; 0 0 1]; % ƽ�Ƶı任���� 

for i = 1 : R
    for j = 1 : C
        temp = [i; j; 1];
        temp = tras * temp; % ����˷�
        x = temp(1, 1);
        y = temp(2, 1);
        % �任���λ���ж��Ƿ�Խ��
        if (x <= R) & (y <= C) & (x >= 1) & (y >= 1)
            res(x, y) = img(i, j);
        end
    end
end;