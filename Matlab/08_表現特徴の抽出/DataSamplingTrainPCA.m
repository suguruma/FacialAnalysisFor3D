% SamplingDataTrainPCA.m
% 2015/10/20
% ランダムにサンプリングしたデータ(DataSampling)に
% trainPCAをかける

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


SampleData = zeros(sample,IndexSize*3);
for cnt = 1:sample
    Input = xlsread(sprintf(FileName,IndexSize,IndexSize,cnt));
    SampleData(cnt,:) = reshape(Input',IndexSize*dim,1)';
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
    contribution(:,cnt) = cumsum(variances) ./ sum(variances);

    %     フィッシャー線形判別式によるランキング
    if(cnt <= half) % test:om
        [s i] = rankfisher(scores,[half-1 half]);
    else % test:hm
        [s i] = rankfisher(scores,[half half-1]);
    end;
    index = i;

    % 平均形状を求める
    meanshape = reshape(mean(Train),dim,IndexSize)';

    
    % データの出力
    xlswrite(sprintf('TrainPCA/%d/coefs_%d_%d.xls',IndexSize,IndexSize,cnt),coefs);
    xlswrite(sprintf('TrainPCA/%d/scores_%d_%d.xls',IndexSize,IndexSize,cnt),scores);
    xlswrite(sprintf('TrainPCA/%d/variances_%d_%d.xls',IndexSize,IndexSize,cnt),variances);
    xlswrite(sprintf('TrainPCA/%d/index_%d_%d.xls',IndexSize,IndexSize,cnt),index);
    xlswrite(sprintf('TrainPCA/%d/mean_%d_%d.xls',IndexSize,IndexSize,cnt),meanshape);

    display(cnt)
    toc;
end;




