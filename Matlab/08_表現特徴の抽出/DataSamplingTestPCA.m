% DataSamplingTestPCA.m
% 2015/06/02

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
num_om = half;
num_hm = half;

% データの読み込み
FileName = 'SamplingData/%d/samplingdata_%d_%d.xls';
IndexSize = 5621;
dim = 3;

CoefName = 'TrainPCA/%d/coefs_%d_%d.xls';
MeanName = 'TrainPCA/%d/mean_%d_%d.xls';

SampleData = zeros(sample,IndexSize*3);
for cnt = 1:sample
    Input = xlsread(sprintf(FileName,IndexSize,IndexSize,cnt));
    SampleData(cnt,:) = reshape(Input',1,IndexSize*dim,1)';
    toc;
end;
display('データの読み込み終了');


for cnt = 1:sample
    CoefData = xlsread(sprintf(CoefName,IndexSize,IndexSize,cnt));
    MeanData = xlsread(sprintf(MeanName,IndexSize,IndexSize,cnt));
    MeanData = reshape(MeanData',1,IndexSize*3);

    testData = SampleData(cnt,:) - MeanData;
    testScore = testData / CoefData';

    xlswrite(sprintf('TestPCA/%d/testscores_%d_%d.xls',IndexSize,IndexSize,cnt),testScore);

end;
