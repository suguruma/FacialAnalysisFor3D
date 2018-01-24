%3次元顔形状データにおける特徴点座標の計算
%特徴点座標を読み込み，全点の直交座標から特徴点座標（x,y,z）を取得

%初期化
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
    %特徴点座標を読み込む
    readData = sprintf(inName1, Num);
    fp = fopen(readData, 'r');
    for i = 1:12
        fgets(fp);
    end;
    readLand = fscanf(fp, '%s %d %d %d %d %d %d %d');
    land2D = reshape(readLand, 8, landNum)';

    %特徴点座標（2次元画像上）から3次元座標の番号を計算する
    number = zeros(1, landNum);
    for i = 1:landNum
        number(i) = 360 * (400 - land2D(i, 6)) + land2D(i, 5) + 1;
    end;
    % 注意!!!逆になるから400から引いてる
    %全点の直交座標から特徴点座標を読み込む
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