% DataSampling.m
% 2015/10/20
% �_�Q�f�[�^(30000�_�ȏ�)����T���v�����O����v���O����

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
PointNum = 5621;

FileName = 'trimData/trimdata%d.xls';
IndexName = 'indexData/aligntrim_index%d.xls';
IndexData = xlsread(sprintf(IndexName,50));
point = size(IndexData,1);

% �����_���ɓ_�̑I��
randomNum(:,1) = 1:point;
randomNum(:,2) = rand(point,1);
sortNum = sortrows(randomNum(:,2));
SampleIndex = [];
for cnt = 1:point
    if(randomNum(cnt,2) <= sortNum(PointNum,1))
        SampleIndex = [SampleIndex;cnt];
    end;
    toc;
end;

% �f�[�^�̓ǂݍ��݂Ə����o��
for cnt = 1:sample
    Index = xlsread(sprintf(IndexName,cnt));
    Input = xlsread(sprintf(FileName,cnt));
    SampleData = Input(Index(SampleIndex(:)),:);
    xlswrite(sprintf('SamplingData/%d/samplingdata_%d_%d.xls',PointNum,PointNum,cnt),SampleData);

%     figure;
%     plot3(Input(:,1),Input(:,2),Input(:,3),'w.');
%     hold on
%     plot3(SampleData(:,1),SampleData(:,2),SampleData(:,3),'r.','MarkerSize',4);
%     hold off 
% 
toc;
end;



