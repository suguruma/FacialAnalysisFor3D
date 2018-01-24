% LocalFeatureTestPCA.m
% 2015/02/04

% clear all;
clc;
tic;

sample = 200;
half = sample / 2;
num_om = half;
num_hm = half;

% データの読み込み
threshold = 90;
FileName = 'trimData/trimdata%d.xls';
TPSIndexName = 'indexData/aligntrim_index%d.xls';
PointIndex = xlsread(sprintf('/LocalFeatureIndex_%d.xls',threshold));
IndexSize = size(PointIndex,1);
dim = 3;

CoefName = 'TrainPCA/coefs_%d_%d.xls';
MeanName = 'TrainPCA/mean_%d_%d.xls';

SampleData = zeros(sample,IndexSize*3);
for cnt = 1:sample
    TPSIndex = xlsread(sprintf(TPSIndexName,cnt));
    Input = xlsread(sprintf(FileName,cnt));
    SampleData(cnt,:) = reshape(Input(TPSIndex(PointIndex(:)),:)',1,IndexSize*dim);
    toc;
end;
display('データの読み込み終了');


for cnt = 1:sample
    CoefData = xlsread(sprintf(CoefName,threshold,cnt));
    MeanData = xlsread(sprintf(MeanName,threshold,cnt));
    MeanData = reshape(MeanData',1,IndexSize*3);
    
    testData = SampleData(cnt,:) - MeanData;
    testScore = testData / CoefData';
    
    xlswrite(sprintf('TestPCA/testscores_%d_%d.xls',threshold,cnt),testScore);

end;
