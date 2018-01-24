% LocalFeatureClusteringTestPCA.m
% 2015/04/08
% �Ǐ�������k-means�g���ăN���X�^�����O��
% ����ꂽ�����ɑ΂���PCA������(test)

clear all;
clc;
tic;

sample = 200;
half = sample / 2;

threshold = 90;
ClusterNum = 5;

LocalIndexName = 'LocalFeatureIndex_%d.xls';
ClusterIndexName = 'LF_Clustering_%d_%d.xls';
LocalIndex = xlsread(sprintf(LocalIndexName,threshold));
ClusterIndex = xlsread(sprintf(ClusterIndexName,threshold,ClusterNum));

IndexSize = size(LocalIndex,1);
dim = 3;
InputData = 'trimData/trimdata%d.xls';
TPSIndexData = 'indexData/aligntrim_index%d.xls';
SampleData = zeros(sample,IndexSize*dim);

CoefName = 'TrainPCA/coefs_%d_%d_%d.xls';
MeanName = 'TrainPCA/mean_%d_%d_%d.xls';


% �f�[�^�̓ǂݍ���
for cnt = 1:sample
    Input = xlsread(sprintf(InputData,cnt));
    TPSIndex = xlsread(sprintf(TPSIndexData,cnt));

    TPSInput = Input(TPSIndex(:),:)';
    ReshapeInput = TPSInput(:,LocalIndex(:));
    SampleData(cnt,:) = reshape(ReshapeInput,1,IndexSize*dim);
    toc;
end;

display('�f�[�^�ǂݍ��ݏI��');

for ClusterCnt = 1:ClusterNum
    
    % �N���X�^���Ƃ�sample�W�������
    NewSample = [];
    for cnt = 1:IndexSize
        if(ClusterCnt == ClusterIndex(cnt,1))
            NewSample = [NewSample';SampleData(:,((cnt-1)*dim+1):((cnt-1)*dim+dim))']';
        end;
    end;
    
    NewSampleSize = size(NewSample',1)/3;

    
    for cnt = 1:sample
        CoefData = xlsread(sprintf(CoefName,threshold,ClusterCnt,cnt));
        MeanData = xlsread(sprintf(MeanName,threshold,ClusterCnt,cnt));

        testData = NewSample(cnt,:) - reshape(MeanData',1,NewSampleSize*dim);
        testScore = testData / CoefData';

        xlswrite(sprintf('TestPCA/testscores_%d_%d_%d.xls',threshold,ClusterCnt,cnt),testScore);
    end;
end;
