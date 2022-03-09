function img2 = ImageTranslate(img1, delta_v, delta_h)%�����ֱ�Ϊͼ�����ˮƽλ�ơ���ֱλ��
    %%ȡλ�Ƶľ���ֵ
    abs_delta_v = abs(delta_v);
    abs_delta_h = abs(delta_h);
    %%��ͼ��uint8���͵�����ת��Ϊdouble���͵�ͬʱ�������ݷ�Χ��ԭ����0~255ӳ�䵽0~1�����Կ������ݵ�һ�ֹ�һ��,�Ա����
    img = im2double(img1);
    %��ȡͼ��Ŀ�͸��Լ���������ͼ�����ݵ�����r������c�Լ�ά��l
    [r,c,l] = size(img);
    
    %���ƽ�Ƶ�ˮƽλ�ƻ�ֱλ�ƴ���ͼ��Ŀ�Ȼ�߶ȣ���ֱ�������ɫͼ�񼴿�
    if(abs_delta_h >= r || abs_delta_v >= c)
       img2 = zeros(r,c,l);
       return
    elseif(abs_delta_h == 0 && abs_delta_v == 0)%��ˮƽ�ʹ�ֱλ�ƶ�Ϊ0ʱ�����ԭͼ��
        img2 = img;
        return
    end
    
    %%�������
    rows = zeros(abs_delta_h,c,l);%���ڲ���ͼ����Ϸ����·�������ֱλ��Ϊ��ʱ����ͼ����·�
    cols = zeros(r + abs_delta_h,abs_delta_v,l);%���ڲ���ͼ����󷽻��ҷ�����ˮƽλ��Ϊ��ʱ����ͼ����ҷ�
    
    if(delta_v < 0)%��ˮƽλ��Ϊ��ʱ����ͼ����·�
        img = [img;rows];
        if(delta_h < 0)%����ֱλ��Ϊ��ʱ����ͼ����ҷ�
            img = [img,cols];
            img2 = img(abs_delta_h:end,abs_delta_v:end,:);%������½�
        elseif(delta_h >= 0)%����ֱλ��Ϊ��ʱ����ͼ�����
            img = [cols,img];
            img2 = img(max(abs_delta_h,1):end,1:c,:);%������½�
        end
    elseif(delta_v > 0)%��ˮƽλ��Ϊ��ʱ����ͼ����Ϸ�
        img = [rows;img];
        if(delta_h < 0)
            img = [img,cols];
            img2 = img(1:r,abs_delta_v:end,:);%������Ͻ�
        elseif(delta_h >= 0)
            img = [cols,img];
            img2 = img(1:r,1:c,:);%������Ͻ�
        end
    else%��ˮƽλ��Ϊ0ʱ��ֱ���򲻲���
        if(delta_h < 0)
            img = [img;rows];
            img2 = img(1:r,abs_delta_v:end,:);%���ͼ���ҷ�
        elseif(delta_h >= 0)
            img = [cols,img];
            img2 = img(1:r,1:c,:);%���ͼ����
        end
    end
    
    [r2,c2,l2] = size(img2);
end