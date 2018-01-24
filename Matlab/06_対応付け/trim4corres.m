%�ʒu���킹��̃g���~���O
%���͂����͈̔͂𓝈ꂷ�邽�߂ɁA�����W�ϊ��𗘗p���Ċ�`��̃g���~���O���s��

%initialize----------------------------------------------------------------
clear all
clc;
tic;

%set parameter-------------------------------------------------------------
rangeV1 = (pi / 3.0);
rangeV2 = (pi / 6.0);
rangeH = (pi / 3.2);
sample = 200;
half = sample / 2;

%input & output------------------------------------------------------------
inName = 'alignData/aligndata%d.xls';
outName = 'trimData/trimdata%d.xls';

for dn = 1:sample % �ʒu���킹�O�Ȃ�25����� or �ʒu���킹��Ȃ�50�����
    %read dataset----------------------------------------------------------
    facedata = sprintf(inName, dn);
    saveface = sprintf(outName, dn);
    dataset = xlsread(facedata);
    datasize = size(dataset);
    display('Open file...');

    %extract data----------------------------------------------------------
    %transformation to sphere coordinate
    [sphdata(:, 1), sphdata(:, 2), sphdata(:, 3)] = cart2sph(dataset(:, 1), dataset(:, 2), dataset(:, 3));
    
    %trimming
    count = 1;
%     sphtemp = zeros(40000, 3); %40000�͎c���_��葽�߂̐�����K���Ɍ���A��ŗv�f�̖������͏��O����
    sphtemp = zeros(2500, 3); %40000�͎c���_��葽�߂̐�����K���Ɍ���A��ŗv�f�̖������͏��O����
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
    
    %display trimming data-------------------------------------------------
%     figure;plot3(sphdata(:, 1), sphdata(:, 2), sphdata(:, 3), 'c.', 'markersize', 4);
%     hold on; plot3(sphtrim(:, 1), sphtrim(:, 2), sphtrim(:, 3), 'g.', 'markersize', 4); hold off;
%     figure;plot3(dataset(:, 1), dataset(:, 2), dataset(:, 3),'c.', 'markersize', 4);
%     hold on; plot3(trimdata(:, 1), trimdata(:, 2), trimdata(:, 3), 'g.', 'markersize', 4); hold off;
    
    %write trimming dataset------------------------------------------------
    xlswrite(saveface, trimdata);

    
    clear dataset sphdata sphtemp sphtrim trimdata datasize r c
end;

clear rangeV1 rangeV2 rangeH facedata saveface dn inName outName 
toc;
display('Trimming is completed. ');