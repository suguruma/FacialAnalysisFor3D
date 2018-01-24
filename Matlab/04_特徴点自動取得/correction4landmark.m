%correction of landmark location
%サンプリング時に取り除いた平行移動の成分を特徴点に戻す

%初期化-------------------------------------
clear all
clc;
tic;

% %input & output 
% inName1 = 'readData/om_data%d.xls';
% inName2 = 'Landmark3D/omland_cart%d.xls';
% outName = 'Landmark3D_c/omland_cart_c%d.xls';

inName1 = 'readData/hm_data%d.xls';
inName2 = 'Landmark3D/hmland_cart%d.xls';
outName = 'Landmark3D_c/hmland_cart_c%d.xls';

%the number of sample
cnt = 1;
sample = 200;
half = sample / 2;

for dn = cnt:half
% dn = 16;
    %データ入力-----------------
    openData_raw = sprintf(inName1, dn);
    openData_land = sprintf(inName2, dn);
    data_raw = xlsread(openData_raw);
    data_land = xlsread(openData_land);
    
    display('File open ...');

    %重心を戻す-----------------
    datasize_land = size(data_land);
    centroid = mean(data_raw);
    centroidmat_land = repmat(centroid, datasize_land(1), 1);
    data_rawland = data_land + centroidmat_land;

    %保存
    saveface_land = sprintf(outName, dn);
    xlswrite(saveface_land, data_rawland);
    
    %表示
%     figure;plot3(data_raw(:, 1), data_raw(:, 2), data_raw(:, 3), '.c',  'MarkerSize', 4);
%     hold on
%     plot3(data_rawland(:, 1), data_rawland(:, 2), data_rawland(:, 3), '.b', 'MarkerSize', 16);
%     hold off;
%     az = 75;
%     el = -12;
%     view(az, el);
    toc;
    clear data_raw data_land centroidmat_land data_rawland
end;

toc;
display('All processing is done.');
clear az el dn sample inName1 inName2 outName