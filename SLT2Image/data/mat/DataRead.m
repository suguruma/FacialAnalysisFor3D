%stl�f�[�^�̓ǂݏo��
%���s���ԒZ�k�̂��߂ɁAstl�f�[�^��ǂݏo���Axls�t�@�C���Ƃ��ĕۑ�����

%initialize
clear all
clc;
tic;

%input & output 
inName = 'rawData/om%d.stl';
outName = 'omvertex%d.xls';

%the number of sample
sample = 2;

%read dataset--------------------------------------------------------------
for Num = 1:sample,
    facedata = sprintf(inName, Num);
    fp1 = fopen(facedata);
    display('File open ...');

    %�t�@�C�������[�h����--------------------------------------------------------
    fgets(fp1); %�ŏ���1�s���X�L�b�v
    readStl = fscanf(fp1, '%s %s %f %f %f\n%s %s\n%s %f %f %f\n%s %f %f %f\n%s %f %f %f\n%s\n%s');
    Stlsize = size(readStl);
    readStl(Stlsize(1)-11:Stlsize(1), :) = []; %�Ō��1�s�����폜

    %���_���W�݂̂̍s��𐶐�----------------------------------------------------
    %65�s��1�Z�b�g�@�����C65n+12�`14���@���x�N�g�����C65n+30�`32�C65n+39�`41�C65n+48�`50�����_
    Stlsize = size(readStl);
    for i = 0:(Stlsize(1)/65-1)
        vertex1(3*i+1:3*i+3, :) = readStl(65*i+30:65*i+32, :);
        vertex2(3*i+1:3*i+3, :) = readStl(65*i+39:65*i+41, :);
        vertex3(3*i+1:3*i+3, :) = readStl(65*i+48:65*i+50, :);
    end;
    
    %�]�u
    vertex1 = reshape(vertex1, 3, Stlsize(1)/65)';
    vertex2 = reshape(vertex2, 3, Stlsize(1)/65)';
    vertex3 = reshape(vertex3, 3, Stlsize(1)/65)';
    
    %�A��
    vertexAll = vertcat(vertex1, vertex2, vertex3);
    dataset = unique(vertexAll, 'rows');

    clear readStl
    display('"face vertex" information memory load done...');

    %save sampling data--------------------------------------------------------
    saveface = sprintf(outName, Num);
    xlswrite(saveface, dataset)
    clear vertex1 vertex2 vertex3 vertexAll dataset facedata saveface;
end;

toc;
display('All processing is done.');

%free memory-------------------------------------------------------------------
clear inName outName Num sample
