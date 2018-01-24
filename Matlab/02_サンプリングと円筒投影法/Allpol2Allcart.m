%サンプリングデータの直交座標への変換
%特徴点の位置を計算するために、直交座標の場合も計算しておく

clear all
clc;
tic;

%sampling size
shapeSize = 400 * 360;

% input & output 
% inName = 'polData/hmsample%d.xls';
% outName = 'cartData/hmcart%d.xls';
% 
inName = 'polData/omsample%d.xls';
outName = 'cartData/omcart%d.xls';

%the number of sample
sample = 200;
half = sample / 2;

for Num = 1:half
% Num = 12;
    %pol2cart
    readXLS = sprintf(inName, Num);
    coord = xlsread(readXLS);

    land = zeros(shapeSize, 3);
    [land(:, 1), land(:, 2), land(:, 3)] = pol2cart(coord(:, 1), coord(:, 2), coord(:, 3));

    %画像表示
%     figure;plot3(land(:, 1), land(:, 2), land(:, 3), '.b', 'MarkerSize', 2);
%     az = 70;
%     el = -30;
%     view(az, el);

    %xls形式で保存する
    writeName = sprintf(outName, Num);
    [status, message] = xlswrite(writeName, land);
    display(Num);
    toc;
end;

toc;
display('All processing is done.');
clear coordX coordY coordZ writeName