%3������`��f�[�^�ɂ���������_���W�̌v�Z
%�����_���W��ǂݍ��݁C�S�_�̒������W��������_���W�ix,y,z�j���擾

%������
clear all
clc;
tic;

% %input & output 
% inName1 = 'Landmark2D/omland%d.txt';
% inName2 = 'cartData/omcart%d.xls';
% outName = 'Landmark3D/omland_cart%d.xls';

inName1 = 'Landmark2D/hmland%d.txt';
inName2 = 'cartData/hmcart%d.xls';
outName = 'Landmark3D/hmland_cart%d.xls';

%the number of landmarks & read number
landNum = 16;
cnt = 1;
sample = 200; 
half = sample / 2;

%sampling size
shapeSizeV = 400;
shapeSizeH = 360;
shapeSize = shapeSizeV * shapeSizeH;

for Num = 1:half
% Num = 16;
    %�����_���W��ǂݍ���
    readData = sprintf(inName1, Num);
    fp = fopen(readData, 'r');
    for i = 1:12
        fgets(fp);
    end;
    readLand = fscanf(fp, '%s %d %d %d %d %d %d %d');
    land2D = reshape(readLand, 8, landNum)';

    %�����_���W�i2�����摜��j����3�������W�̔ԍ����v�Z����
    number = zeros(1, landNum);
    for i = 1:landNum
        number(i) = 360 * (400 - land2D(i, 6)) + land2D(i, 5) + 1;
    end;
    % ����!!!�t�ɂȂ邩��400��������Ă�
    %�S�_�̒������W��������_���W��ǂݍ���
    readXLS = sprintf(inName2, Num);
    Cartcd = xlsread(readXLS);
    land3D = zeros(landNum, 3);
    for i = 1:landNum,
        for j = 1:3,
            land3D(i, j) = Cartcd(number(i), j);
        end;
    end;

    writeXLS = sprintf(outName, Num);
    [status, message] = xlswrite(writeXLS, land3D);
    toc;
end;
toc;
display('All processing is done.');
clear i j Cartcd writeXLS readLand readData readXLS Num ans fp sample landNum
clear inName1 inName2 outName shapeSize shapeSizeV shapeSizeH 