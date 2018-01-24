% LocalFeatureTrainPCA.m
% 2015/02/04

clear all;
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
PointIndex = xlsread(sprintf('LocalFeatureIndex_%d.xls',threshold));
IndexSize = size(PointIndex,1);
dim = 3;

SampleData = zeros(sample,IndexSize*3);
for cnt = 1:sample
    TPSIndex = xlsread(sprintf(TPSIndexName,cnt));
    Input = xlsread(sprintf(FileName,cnt));
    SampleData(cnt,:) = reshape(Input(TPSIndex(PointIndex(:)),:)',1,IndexSize*dim);
    toc;
end;
display('データの読み込み終了');

% PCA
for cnt = 1:sample
    % TrainとTestにSampleDataを分割
    % cnt番目がテストデータ
    Train = SampleData;
    Test = Train(cnt,:);
    Train(cnt,:) = [];

    % PCA
    [coefs,scores,variances,t2] = princomp(Train, 'econ');
    
%     フィッシャー線形判別式によるランキング
    if(cnt <= half) % test:om
        [s i] = rankfisher(scores,[half-1 half]);
    else % test:hm
        [s i] = rankfisher(scores,[half half-1]);
    end;
    index = i;
    
    % 平均形状を求める
    meanshape = reshape(mean(Train),dim,IndexSize)';
    % mh使わないので今はおいとく
    if(cnt <= half) % test:om
        mean_om = reshape(mean(Train(1:half-1,:)),dim,IndexSize)';
        mean_hm = reshape(mean(Train(half:sample-1,:)),dim,IndexSize)';
    else % test:hm
        mean_om = reshape(mean(Train(1:half,:)),dim,IndexSize)';
        mean_hm = reshape(mean(Train(half+1:sample-1,:)),dim,IndexSize)';
    end;
    
    % データの出力
    xlswrite(sprintf('TrainPCA/coefs_%d_%d.xls',threshold,cnt),coefs);
    xlswrite(sprintf('TrainPCA/scores_%d_%d.xls',threshold,cnt),scores);
    xlswrite(sprintf('TrainPCA/variances_%d_%d.xls',threshold,cnt),variances);
    xlswrite(sprintf('TrainPCA/index_%d_%d.xls',threshold,cnt),index);
    xlswrite(sprintf('TrainPCA/mean_%d_%d.xls',threshold,cnt),meanshape);
    display(cnt)
    toc;
end;

display(sprintf('threshold:%d',threshold));


