%円筒座標変換のためのサンプリング
%顔の範囲を限定し、円筒座標系に変換後に補間を利用してサンプリングする
%顔形状を構成する点数が個人により違うため、一人ずつ調整しながら行う

%initialize
clear all
clc;
tic;

sample = 200;
half = sample / 2;
%set parameter1------------------------------------------------------------
slice = 400;
range = (pi / 2.0);   %-90°～90°;
angle = pi * 0.5 / 180.0; %0.5°間隔;
thetaRange = -range+(pi*0.25/180):angle:range-(pi*0.25/180);
sliceNo = 400;
rangeNo = 360;
trimsize = 32000; %残す点数、顔形状が大きいor小さいに応じて1000点刻みくらいで調整
ratioZ = 0.1; %閾値
ratioX = 0.5; %両方とも実験から判断して決定している


%read dataset--------------------------------------------------------------
% dn = 1; %読み込むデータ番号
om_index=[69;72;83;86;89;98;102;108;111;113;
    116;303;124;126;128;130;131;132;134;139;
    143;147;148;149;151;152;153;154;174;175;
    176;178;179;180;181;182;183;188;189;190;
    191;192;193;194;195;196;201;202;204;205;
    207;209;213;214;216;217;218;219;220;221;
    222;224;225;226;227;232;233;234;235;236;
    237;238;239;240;241;243;244;245;246;247;
    249;254;256;257;258;261;264;265;268;269;
    281;287;290;294;295;296;297;298;299;300;];

for cnt = 1:half
% cnt = 12;
    %input & output
    inName = '3DData_ChangeAxis/data%d.xls';
    outName = 'polData/omsample%d.xls';

    facedata = sprintf(inName, om_index(cnt));
    
    fp = fopen(facedata);
    
    if(fp == -1)
        clear fp
    else
        dataset = xlsread(facedata);

%         figure;plot3(dataset(:, 1), dataset(:, 2), dataset(:, 3),'r.', 'markersize', 4);
        display('All data memory load done...');

        %normalize data1-----------------------------------------------------------
        %translate to center(後で戻す必要がある)
        datasize = size(dataset);
        centroid = mean(dataset);
        centroidmat = repmat(centroid, datasize(1), 1);
        dataset = dataset - centroidmat;

        %index
        dataset = dataset';
        alNorm = sum(dataset .* dataset);
        [alNorm, indexmat] = sort(alNorm);

        trim = zeros(3, trimsize);

        %trimming(distance & threshold) 原点からの距離と閾値でサンプリング範囲を制限
        limitX = max(dataset(1, :)) - (max(dataset(1, :)) - min(dataset(1, :))) * ratioX;
        limitZ = max(dataset(3, :)) - (max(dataset(3, :)) - min(dataset(3, :))) * ratioZ;
        count = 1;
        for i = 1:datasize(1)
            if count <= trimsize && dataset(1, indexmat(i)) > limitX && dataset(3, indexmat(i)) < limitZ
                trim(:, count) = dataset(:, indexmat(i));
                count = count + 1;
            else
                continue;
            end;
        end;

        trim = trim';
%         figure;plot3(dataset(1, :), dataset(2, :), dataset(3, :),'c.', 'markersize', 4);
%         hold on; plot3(trim(:, 1), trim(:, 2), trim(:, 3),'g.', 'markersize', 4); hold off;
%         clear dataset poltemp indexmat centroidmat alNorm datasize
        display('Dawn sampling is completed. ');

        %Cylindrical Transformation------------------------------------------------
        %memo:[THETA RHO Z] = cart2pol(x, y, z)
        [poldata(:, 1), poldata(:, 2), poldata(:, 3)] = cart2pol(trim(:, 1), trim(:, 2), trim(:, 3));
%         figure;plot3(poldata(:, 1), poldata(:, 2), poldata(:, 3), 'g.', 'markersize', 4);
        display('Data conversion is completed (cart2pol). ');

        %set parameter2------------------------------------------------------------
        maxval = floor(max(poldata(:, 3))) + 1;
        minval = floor(min(poldata(:, 3)));
        step = (maxval - minval) / (slice-1);
        zRange = minval:step:maxval;

        %sampling------------------------------------------------------------------
        %set grid to follow parameter & interpolate
        [thetaGrid, zGrid] = meshgrid(thetaRange, zRange);
        rhoGrid = griddata(poldata(:, 1), poldata(:, 3), poldata(:, 2), thetaGrid, zGrid);
        %rhoGrid(isnan(rhoGrid)) = 0;

        %determine sampling point
        theta = reshape(thetaGrid', sliceNo*rangeNo, 1);
        rho = reshape(rhoGrid', sliceNo*rangeNo, 1);
        z = reshape(zGrid', sliceNo*rangeNo, 1);
        polGrid = horzcat(theta, rho, z);

%         hold on; plot3(polGrid(:, 1), polGrid(:, 2), polGrid(:, 3),'b.', 'markersize', 4); hold off;
%         clear theta rho z thetaGrid rhoGrid zGrid thetaRange zRange
        display('Data sampling is over.');

        %reconstruct dataset-------------------------------------------------------
        [redata1(:, 1), redata1(:, 2), redata1(:, 3)] = pol2cart(poldata(:, 1), poldata(:, 2), poldata(:, 3));
        [redata2(:, 1), redata2(:, 2), redata2(:, 3)] = pol2cart(polGrid(:, 1), polGrid(:, 2), polGrid(:, 3));
%         figure;plot3(redata1(:, 1), redata1(:, 2), redata1(:, 3),'g.', 'markersize', 4);
%         hold on; plot3(redata2(:, 1), redata2(:, 2), redata2(:, 3),'b.', 'markersize', 9); hold off;

        %save sampling data--------------------------------------------------------
        saveface = sprintf(outName, cnt);
        xlswrite(saveface, polGrid);

        toc;
        display('All processing is done.');
        display(om_index(cnt));
    end;
end;
%free memory---------------------------------------------------------------
clear trimsize mode count step angle range slice dn facedata inName outName
clear i j maxval minval sliceNo rangeNo ratioA ratioX ratioZ limitX limitZ;