% LocalFeatureClusteringPCA.m
% 2015/04/08
% �Ǐ�������k-means�g���ăN���X�^�����O��
% ����ꂽ�����ɑ΂���PCA������

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
        Train = NewSample;
        Test = Train(cnt,:);
        Train(cnt,:) = [];

        % PCA
        [coefs,scores,variances,t2] = princomp(Train, 'econ');

        %     �t�B�b�V���[���`���ʎ��ɂ�郉���L���O
        if(cnt <= half) % test:om
            [s i] = rankfisher(scores,[half-1 half]);
        else % test:hm
            [s i] = rankfisher(scores,[half half-1]);
        end;
        index = i;

        % ���ό`������߂�
        meanshape = reshape(mean(Train),dim,NewSampleSize)';

        % �f�[�^�̏o��
        xlswrite(sprintf('TrainPCA/coefs_%d_%d_%d.xls',threshold,ClusterCnt,cnt),coefs);
        xlswrite(sprintf('TrainPCA/scores_%d_%d_%d.xls',threshold,ClusterCnt,cnt),scores);
        xlswrite(sprintf('TrainPCA/variances_%d_%d_%d.xls',threshold,ClusterCnt,cnt),variances);
        xlswrite(sprintf('TrainPCA/index_%d_%d_%d.xls',threshold,ClusterCnt,cnt),index);
        xlswrite(sprintf('TrainPCA/mean_%d_%d_%d.xls',threshold,ClusterCnt,cnt),meanshape);

        display(cnt)
        toc;

    end;
end;

