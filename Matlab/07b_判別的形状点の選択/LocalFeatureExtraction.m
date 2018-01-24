% LocalFeatureExtraction.m
% 2015/01/27

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
num_om = half;
num_hm = half;

% データの読み込み
FileName = 'trimData/trimdata%d.xls';
IndexName = 'indexData/aligntrim_index%d.xls';
IndexData = xlsread(sprintf(IndexName,94));
point = size(IndexData,1);
dim = 3;

SampleData_X = zeros(sample,point);
SampleData_Y = zeros(sample,point);
SampleData_Z = zeros(sample,point);

for cnt = 1:sample
    Index = xlsread(sprintf(IndexName,cnt));
    Input = xlsread(sprintf(FileName,cnt));
    SampleData_X(cnt,:) = Input(Index(:),1)';
    SampleData_Y(cnt,:) = Input(Index(:),2)';
    SampleData_Z(cnt,:) = Input(Index(:),3)';
    toc;
end;


display('データの読み込み終了');

% 各点の分散もとめていく
ScoreData = zeros(point,3);

for num = 1:point
%     ある点に対する全データのX,Y,Z
    PointData = [SampleData_X(:,num) SampleData_Y(:,num) SampleData_Z(:,num)];
%     クラスの平均と分散を求める
    Pointmean_om = mean(PointData(1:half,:));
    Pointmean_hm = mean(PointData(half+1:sample,:));
    Pointvar_om = var(PointData(1:half,:));
    Pointvar_hm = var(PointData(half+1:sample,:));
    
    mean_om = Pointmean_om * Pointmean_om';
    mean_hm = Pointmean_hm * Pointmean_hm';
    var_om = Pointvar_om * Pointvar_om';
    var_hm = Pointvar_hm * Pointvar_hm';
    
%     クラス内分散とクラス間分散を求める
    var_b = ((num_om * num_hm) * (mean_om - mean_hm)^2) / (num_om + num_hm)^2;
    var_w = ((num_om * var_om) + (num_hm * var_hm)) / (num_om + num_hm);
    fisher = var_b / var_w;

%     fisherスコア
    ScoreData(num,:) = [var_b var_w fisher];
    toc;
end;

% 正規化するスコア
min_b = min(ScoreData(:,1));
min_w = min(ScoreData(:,2));
max_b = max(ScoreData(:,1));
max_w = max(ScoreData(:,2));

new_b = (ScoreData(:,1) - min_b) / (max_b - min_b);
new_w = (ScoreData(:,2) - min_w) / (max_w - min_w);

new_fisher = new_b ./ new_w;


medianValue = median(ScoreData);
meanValue = mean(ScoreData);

meanFace = [mean(SampleData_X);mean(SampleData_Y);mean(SampleData_Z)]';
figure;
plot3(meanFace(:,1),meanFace(:,2),meanFace(:,3),'b.','MarkerSize',4);

LowScoreData = [];
HighScoreData = [];
% threshold  = meanValue(:,3);
threshold = 180;

for cnt = 1:point
    if(ScoreData(cnt,3) < threshold);
        LowScoreData = [LowScoreData;meanFace(cnt,:)];
    else
        HighScoreData = [HighScoreData;meanFace(cnt,:)];
    end;
end;

figure;
plot3(LowScoreData(:,1),LowScoreData(:,2),LowScoreData(:,3),'k.','MarkerSize',4);
hold on
plot3(HighScoreData(:,1),HighScoreData(:,2),HighScoreData(:,3),'r.','MarkerSize',4);
hold off

display('閾値処理終了');

% 局所特徴書き出し
xlswrite(sprintf('LocalFeature_%d.xls',threshold),HighScoreData);

% 閾値処理 for 点抽出
IndexData = [];
for cnt = 1:point
    if(ScoreData(cnt,3) > threshold)
        IndexData = [IndexData;cnt];
    end;
end;

% 点のインデックス書き出し
xlswrite(sprintf('LocalFeatureIndex_%d.xls',threshold),IndexData);

display('閾値処理(点抽出)完了');
