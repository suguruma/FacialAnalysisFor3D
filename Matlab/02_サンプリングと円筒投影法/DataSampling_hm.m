%�~�����W�ϊ��̂��߂̃T���v�����O
%��͈̔͂����肵�A�~�����W�n�ɕϊ���ɕ�Ԃ𗘗p���ăT���v�����O����
%��`����\������_�����l�ɂ��Ⴄ���߁A��l���������Ȃ���s��

%initialize
clear all
clc;
tic;

sample = 200;
half = sample / 2;
%set parameter1------------------------------------------------------------
slice = 400;
range = (pi / 2.0);   %-90���`90��;
angle = pi * 0.5 / 180.0; %0.5���Ԋu;
thetaRange = -range+(pi*0.25/180):angle:range-(pi*0.25/180);
sliceNo = 400;
rangeNo = 360;
trimsize = 32000; %�c���_���A��`�󂪑傫��or�������ɉ�����1000�_���݂��炢�Œ���
ratioZ = 0.1; %臒l
ratioX = 0.5; %�����Ƃ��������画�f���Č��肵�Ă���


%read dataset--------------------------------------------------------------
% dn = 1; %�ǂݍ��ރf�[�^�ԍ�
hm_index=[5;15;18;24;30;33;60;62;70;78;
    79;81;82;84;104;827;106;109;110;112;
    114;121;123;125;129;135;140;141;144;146;
    150;155;157;165;259;270;286;292;302;310;
    313;463;465;470;475;478;494;495;501;502;
    506;518;521;529;535;536;545;557;559;560;
    563;614;634;647;650;652;660;663;682;686;
    689;706;711;720;727;739;748;758;759;762;
    770;771;775;777;778;779;781;782;784;786;
    787;788;793;795;797;801;803;804;805;809;];

for cnt = 1:half
% cnt = 16;
    %input & output
    inName = '3DData_ChangeAxis/data%d.xls';
    outName = 'polData/hmsample%d.xls';

    facedata = sprintf(inName, hm_index(cnt));
    
    fp = fopen(facedata);
    
    if(fp == -1)
        clear fp
    else
        dataset = xlsread(facedata);

%         figure;plot3(dataset(:, 1), dataset(:, 2), dataset(:, 3),'r.', 'markersize', 4);
        display('All data memory load done...');

        %normalize data1-----------------------------------------------------------
        %translate to center(��Ŗ߂��K�v������)
        datasize = size(dataset);
        centroid = mean(dataset);
        centroidmat = repmat(centroid, datasize(1), 1);
        dataset = dataset - centroidmat;

        %index
        dataset = dataset';
        alNorm = sum(dataset .* dataset);
        [alNorm, indexmat] = sort(alNorm);

        trim = zeros(3, trimsize);

        %trimming(distance & threshold) ���_����̋�����臒l�ŃT���v�����O�͈͂𐧌�
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
        display(hm_index(cnt));
    end;
end;
%free memory---------------------------------------------------------------
clear trimsize mode count step angle range slice dn facedata inName outName
clear i j maxval minval sliceNo rangeNo ratioA ratioX ratioZ limitX limitZ;