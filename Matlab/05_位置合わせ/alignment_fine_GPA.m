%�����`��ɂ�����3�����ʒu���킹
%�����_�̍��W����GPA��p���đS�_�̍��W���ʒu���킹����

%������-------------------------------------
clear all
clc;
tic;

%%
%�ʒu���킹���s���f�[�^�̓���-----------------
sample = 200;
half = sample / 2;
landNo = 17;
landmark{sample} = [];
data{sample} = [];

%input & output 
inLand_om = 'Landmark_17/omland_cart_cr%d.xls';
inLand_hm = 'Landmark_17/hmland_cart_cr%d.xls';
inVec_om = 'readData/om_data%d.xls';
inVec_hm = 'readData/hm_data%d.xls';
outLand = 'alignLand/alignland%d.xls';
outVec = 'alignData/aligndata%d.xls';

for i = 1:half
    openLandom = sprintf(inLand_om, i);
    openLandhm = sprintf(inLand_hm, i);
    openDataom = sprintf(inVec_om, i);
    openDatahm = sprintf(inVec_hm, i);
    temp_om = xlsread(openLandom);
    temp_hm = xlsread(openLandhm);
    landmark{i} = temp_om(1:landNo, :);
    landmark{i+half} = temp_hm(1:landNo, :);
    data{i} = xlsread(openDataom);
    data{i+half} = xlsread(openDatahm);
    clear temp_om temp_hm
end;
display('File open ...');

%%
%�ʒu���킹�O�̔�r
figure;plot3(data{1}(:, 1), data{1}(:, 2), data{1}(:, 3), '.b', 'MarkerSize', 1);
hold on;
plot3(data{2}(:, 1), data{2}(:, 2), data{2}(:, 3), '.g', 'MarkerSize', 1);
plot3(data{3}(:, 1), data{3}(:, 2), data{3}(:, 3), '.r', 'MarkerSize', 1);
plot3(data{4}(:, 1), data{4}(:, 2), data{4}(:, 3), '.y', 'MarkerSize', 1);
plot3(data{5}(:, 1), data{5}(:, 2), data{5}(:, 3), '.m', 'MarkerSize', 1);
hold off;
az = 70;
el = -30;
view(az, el);
xlim([-60, 140]);
ylim([-100, 100]);
zlim([-150, 150]);

%%
%---------------�d�݂̌v�Z�J�n---------------
weight = ones(landNo, 1); 
dist = zeros(sample, landNo);
for outloop = 1:landNo
    %�e�_�Ԃ̋������v�Z���ĕۑ�
    for countweight = 1:sample
        for inloop = 1:landNo
            dist(countweight, inloop) = sqrt((landmark{countweight}(outloop, 1) ...
                - landmark{countweight}(inloop, 1))^2 + (landmark{countweight}(outloop, 2) ...
                - landmark{countweight}(inloop, 2))^2 + (landmark{countweight}(outloop, 3) ...
                - landmark{countweight}(inloop, 3))^2);
        end;
    end;
    
    %�e�����̕��U��_���Ɍv�Z
    varVec = var(dist, 1);
    
    %���U�̘a�̋t�����d�ݍs���
    weight(outloop, 1) = 1 / sum(varVec);
end;

%�d�݂̐��K��
normalSum = sum(weight);
weight = weight / normalSum;
display('Calculates the weight is over.');
%---------------�d�݂̌v�Z�I��---------------

%%
%��`��̃x�N�g����-------------------------
alignment1{sample} = []; 
alignment2{sample} = []; 
baseVec = landmark{1}';
alignment1{1} = landmark{1}';
alignment2{1} = data{1}';

%%
%�ŏ��̃A���C�����g---------------------------------------------------------
for i = 2:sample
    [regParams, newVec, ErrorStats] = absor(landmark{i}', baseVec, 'doScale', 'TRUE', 'weights', weight);     
    alignment1{i} = newVec;
    transMat = repmat(regParams.t, 1, size(data{i}, 1));
    alignment2{i} = regParams.s * regParams.R * data{i}' + transMat;
end;
display('First alignment is over.');
clear baseVec landmark data normalSum dist varVec outloop inloop transMat
%�ŏ��̃A���C�����g�@�����܂�------------------------------------------------

%�ŏ��̈ʒu���킹��̔�r
figure;plot3(alignment2{1}(1, :), alignment2{1}(2, :), alignment2{1}(3, :), '.b', 'MarkerSize', 1);
hold on;
plot3(alignment2{2}(1, :), alignment2{2}(2, :), alignment2{2}(3, :), '.g', 'MarkerSize', 1);
plot3(alignment2{3}(1, :), alignment2{3}(2, :), alignment2{3}(3, :), '.r', 'MarkerSize', 1);
plot3(alignment2{4}(1, :), alignment2{4}(2, :), alignment2{4}(3, :), '.y', 'MarkerSize', 1);
plot3(alignment2{5}(1, :), alignment2{5}(2, :), alignment2{5}(3, :), '.m', 'MarkerSize', 1);
hold off;
az = 70;
el = -30;
view(az, el);
xlim([-60, 140]);
ylim([-100, 100]);
zlim([-150, 150]);

%%
%���K�����܂ލăA���C�����g--------------------------------------------------
for ite = 1:5 
    %���ό`����v�Z------------------------------
    meanshape = zeros(3, landNo);
    for count = 1:sample
        meanshape = meanshape + alignment1{count};
    end;
    meanshape = meanshape / sample;
    
    %���ό`��ւ̍ăA���C�����g-------------------    
    for i = 1:sample  
        [regParams, newVec, ErrorStats] = absor(alignment1{i}, meanshape, 'doScale', 'TRUE', 'weights', weight);
        alignment1{i} = newVec;
        transMat = repmat(regParams.t, 1, size(alignment2{i}, 2));
        alignment2{i} = regParams.s * regParams.R * alignment2{i} + transMat;
    end;
end;
display('Alignment is over all');

%%
%�\���p�Ƀx�N�g�����s��ɕό`-----------------
dataN1{sample} = [];
for i = 1:sample
    dataN1{i} = alignment1{i}';
    writeXLS1 = sprintf(outLand, i);
    xlswrite(writeXLS1, dataN1{i});
end;

dataN2{sample} = [];
for i = 1:sample
    dataN2{i} = alignment2{i}';
    writeXLS2 = sprintf(outVec, i);
    xlswrite(writeXLS2, dataN2{i});
end;

%%
%���W�\��------------------------------------
%�ʒu���킹��̔�r
figure;plot3(dataN2{1}(:, 1), dataN2{1}(:, 2), dataN2{1}(:, 3), '.b', 'MarkerSize', 1);
hold on;
plot3(dataN2{2}(:, 1), dataN2{2}(:, 2), dataN2{2}(:, 3), '.g', 'MarkerSize', 1);
plot3(dataN2{3}(:, 1), dataN2{3}(:, 2), dataN2{3}(:, 3), '.r', 'MarkerSize', 1);
plot3(dataN2{4}(:, 1), dataN2{4}(:, 2), dataN2{4}(:, 3), '.y', 'MarkerSize', 1);
plot3(dataN2{5}(:, 1), dataN2{5}(:, 2), dataN2{5}(:, 3), '.m', 'MarkerSize', 1);
hold off;
az = 70;
el = -30;
view(az, el);
xlim([-60, 140]);
ylim([-100, 100]);
zlim([-150, 150]);

%%
toc;
display('All processing is done.');
clear row newVec meanshape rotP rotTheta rotmat scaleLen az el
clear i ite landNo sample half scale count countweight openDataom openDatahm openLandom openLandhm centroid meanCoor
clear inLand_om inLand_hm inVec_om inVec_hm outVec outLand writeXLS1 writeXLS2