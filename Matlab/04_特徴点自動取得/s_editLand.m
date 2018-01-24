%球座標を利用した特徴点の自動取得
%顔形状データを球座標系に投影し、自動で特徴点を取得・追加する

%initialize
clear all
clc;
tic;

%set parameter-------------------------------------------------------------
rangeV1 = (pi / 3.0);
rangeV2 = (pi / 6.0);
rangeH = (pi / 3.2);

%set parameter-------------------------------------------------------------
cnt = 100;
sample = 200;
half = cnt;
% half = sample / 2;
landNo = 16;
accuracy = 0.005; %探索する幅

% input & output 
% inLand = 'Landmark3D_c/omland_cart_c%d.xls';
% inVec = 'readData/om_data%d.xls';
% outLand = 'Landmark_17/omland_cart_cr%d.xls';
% 
inLand = 'Landmark3D_c/hmland_cart_c%d.xls';
inVec = 'readData/hm_data%d.xls';
outLand = 'Landmark_17/hmland_cart_cr%d.xls';

landmark{half} = [];
dataset{half} = [];
for dn = cnt:half
%     dn = 16;
    %---------------------------探索範囲の制限-----------------------------%
    
    %read dataset----------------------------------------------------------
    facedata = sprintf(inVec, dn);
    readData = xlsread(facedata);
    datasize = size(readData);
    display('Open file...');

    %extract data----------------------------------------------------------
    %transformation to sphere coordinate
    [sphdata(:, 1), sphdata(:, 2), sphdata(:, 3)] = cart2sph(readData(:, 1), readData(:, 2), readData(:, 3));
    
    %trimming
    count = 1;
    sphtemp = zeros(40000, 3);%40000は残す点より多めの数字を適当に決定、後で要素の無い所は除外する
    for i = 1:datasize(1)
        if -rangeH < sphdata(i, 1) && sphdata(i, 1) < rangeH && -rangeV1 < sphdata(i, 2) && sphdata(i, 2) < rangeV2
            sphtemp(count, :) = sphdata(i, :);
            count = count + 1;
        end;
    end;
    
    %exeption of 0
    [r, c] = find(sphtemp);
    sphtrim = sphtemp(1:max(r), :);
    
    %transformation to previous coordinate
    [trimdata(:, 1), trimdata(:, 2), trimdata(:, 3)] = sph2cart(sphtrim(:, 1), sphtrim(:, 2), sphtrim(:, 3));
    
    clear sphdata sphtrim
    %---------------------------探索範囲の制限-----------------------------%
    
    %--------------------------ここから追加処理----------------------------%
    
    %Read landmark
    openLand = sprintf(inLand, dn);
    land_temp = xlsread(openLand);
    landmark{dn} = land_temp(1:landNo, :);
    dataset{dn} = trimdata;
    
    %transform to sphere coordinate
    [sphland(:, 1), sphland(:, 2), sphland(:, 3)] = cart2sph(landmark{dn}(:, 1), landmark{dn}(:, 2), landmark{dn}(:, 3));
    [sphdata(:, 1), sphdata(:, 2), sphdata(:, 3)] = cart2sph(dataset{dn}(:, 1), dataset{dn}(:, 2), dataset{dn}(:, 3));
   
    sph_add = 0;
    sph_edit1 = 0;
    sph_edit2 = 1000;
    for pointNo = 1:size(sphdata, 1)
        %add number 17 based on location of number 14 
        if sphdata(pointNo, 2) < sphland(14, 2) && ...
                sphland(16, 1)-accuracy < sphdata(pointNo, 1) && sphdata(pointNo, 1) < sphland(16, 1)+accuracy
            if sphdata(pointNo, 3) > sph_add
                sphland_add = sphdata(pointNo, :);
                sph_add = sphdata(pointNo, 3);
            end;
        end;
        
        %edit number 11 based on location of number 10 & 12
        if sphdata(pointNo, 2) <  sphland(10, 2) && sphdata(pointNo, 2) > sphland(12, 2) && ...
                sphland(16, 1)-accuracy < sphdata(pointNo, 1) && sphdata(pointNo, 1) < sphland(16, 1)+accuracy 
            if sphdata(pointNo, 3) > sph_edit1
                sphland_edit1 = sphdata(pointNo, :);
                sph_edit1 = sphdata(pointNo, 3);
            end;
        end;
        
        %edit number 7 based on location of number 5or9 & 12
        if sphdata(pointNo, 2) <  sphland(5, 2) && sphdata(pointNo, 2) > sphland(12, 2) && ...
                sphland(16, 1)-accuracy < sphdata(pointNo, 1) && sphdata(pointNo, 1) < sphland(16, 1)+accuracy 
            if sphdata(pointNo, 3) < sph_edit2
                sphland_edit2 = sphdata(pointNo, :);
                sph_edit2 = sphdata(pointNo, 3);
            end;
        end;
    end;
    
    
    
    
    %add number 17
    [land_add(1, 1), land_add(1, 2), land_add(1, 3)] = sph2cart(sphland_add(1, 1), sphland_add(1, 2), sphland_add(1, 3));
    landmark{dn}(size(landmark{dn}, 1)+1, :) = land_add;
    
    %edit number 11
    [land_edit1(1, 1), land_edit1(1, 2), land_edit1(1, 3)] = sph2cart(sphland_edit1(1, 1), sphland_edit1(1, 2), sphland_edit1(1, 3));
    landmark{dn}(11, :) = land_edit1;
    
    %edit number 7
    [land_edit2(1, 1), land_edit2(1, 2), land_edit2(1, 3)] = sph2cart(sphland_edit2(1, 1), sphland_edit2(1, 2), sphland_edit2(1, 3));
    landmark{dn}(7, :) = land_edit2;
    
    %display normal coordinate
    figure;plot3(dataset{dn}(:, 1), dataset{dn}(:, 2), dataset{dn}(:, 3), 'c.', 'markersize', 4);
    hold on; 
    plot3(landmark{dn}(:, 1), landmark{dn}(:, 2), landmark{dn}(:, 3), 'g.', 'markersize', 16); 
    plot3(landmark{dn}(17, 1), landmark{dn}(17, 2), landmark{dn}(17, 3), 'b.', 'markersize', 16); 
    plot3(landmark{dn}(7, 1), landmark{dn}(7, 2), landmark{dn}(7, 3), 'r.', 'markersize', 16);
    plot3(landmark{dn}(11, 1), landmark{dn}(11, 2), landmark{dn}(11, 3), 'k.', 'markersize', 16); 
    hold off;
    
    %write edit landmark
%     writename = sprintf(outLand, dn);
%     xlswrite(writename, landmark{dn});
    
    %--------------------------ここまで追加処理----------------------------%
    toc;
    clear trimdata sphdata sphland land_add land_edit1 land_edit2 sphland_add sphland_edit1 sphland_edit2
end;

clear accuracy i inLand inVec landNo openLand outLand sample writename count datasize dn
clear facedata land_temp pointNo rangeH rangeV1 rangeV2 
toc;
display('All processing is done.');