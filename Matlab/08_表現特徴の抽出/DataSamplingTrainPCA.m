% SamplingDataTrainPCA.m
% 2015/10/20
% �����_���ɃT���v�����O�����f�[�^(DataSampling)��
% trainPCA��������

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
num_om = half;
num_hm = half;


% �f�[�^�̓ǂݍ���
FileName = 'SamplingData/%d/samplingdata_%d_%d.xls';

IndexSize = 5621;
dim = 3;


SampleData = zeros(sample,IndexSize*3);
for cnt = 1:sample
    Input = xlsread(sprintf(FileName,IndexSize,IndexSize,cnt));
    SampleData(cnt,:) = reshape(Input',IndexSize*dim,1)';
    toc;
end;
display('�f�[�^�̓ǂݍ��ݏI��');

% PCA
for cnt = 1:sample
    % Train��Test��SampleData�𕪊�
    % cnt�Ԗڂ��e�X�g�f�[�^
    Train = SampleData;
    Test = Train(cnt,:);
    Train(cnt,:) = [];

    % PCA
    [coefs,scores,variances,t2] = princomp(Train, 'econ');
    contribution(:,cnt) = cumsum(variances) ./ sum(variances);

    %     �t�B�b�V���[���`���ʎ��ɂ�郉���L���O
    if(cnt <= half) % test:om
        [s i] = rankfisher(scores,[half-1 half]);
    else % test:hm
        [s i] = rankfisher(scores,[half half-1]);
    end;
    index = i;

    % ���ό`������߂�
    meanshape = reshape(mean(Train),dim,IndexSize)';

    
    % �f�[�^�̏o��
    xlswrite(sprintf('TrainPCA/%d/coefs_%d_%d.xls',IndexSize,IndexSize,cnt),coefs);
    xlswrite(sprintf('TrainPCA/%d/scores_%d_%d.xls',IndexSize,IndexSize,cnt),scores);
    xlswrite(sprintf('TrainPCA/%d/variances_%d_%d.xls',IndexSize,IndexSize,cnt),variances);
    xlswrite(sprintf('TrainPCA/%d/index_%d_%d.xls',IndexSize,IndexSize,cnt),index);
    xlswrite(sprintf('TrainPCA/%d/mean_%d_%d.xls',IndexSize,IndexSize,cnt),meanshape);

    display(cnt)
    toc;
end;




