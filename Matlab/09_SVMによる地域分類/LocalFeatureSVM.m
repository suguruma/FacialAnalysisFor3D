% program/後期/LocalFeature
% LocalFeatureSVM.m
% 2015/02/06

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
baseNo = sample - 2;
threshold = 90;

TrainName = 'TrainPCA/scores_%d_%d.xls';
TestName = 'TestPCA/testscores_%d_%d.xls';
indexName = 'TrainPCA/index_%d_%d.xls';
varName = 'TrainPCA/variances_%d_%d.xls';


result = zeros(sample,baseNo);
for cnt = 1:sample
    % データの読み込み
    trainScore = xlsread(sprintf(TrainName,threshold,cnt));
    testScore = xlsread(sprintf(TestName,threshold,cnt));
%     固有値順
%     index = 1:baseNo;
%     フィッシャースコア順
    index = xlsread(sprintf(indexName,threshold,cnt));
    
%     正規化するときは使う
%     var = xlsread(sprintf(varName,threshold,cnt));
%     variance = sqrt(var)/100;
%     variance = sqrt(var);
    
%     trainScore = trainScore / 100;
%     testScore = testScore / 100;

    %     正規化なし
%     trainData = trainScore;
%     testData = testScore;
%     
    % 正規化1
    max_value = max(trainScore,[],1);
    min_value = min(trainScore,[],1);
    diff = max_value - min_value;
    
    trainData = (trainScore - repmat(min_value,sample-1,1)) ./ repmat(diff,sample-1,1);
    testData = (testScore - min_value) ./ diff;
    
%     正規化2
%     trainData = trainScore ./ repmat(variance',sample-1,1);
%     testData = testScore ./ variance';
    
    % ラベル付け
    if(cnt <= half) % test:om
        trainLabel = [ones(half-1,1);ones(half,1)*2];
        testLabel = 1;
    else % test:hm
        trainLabel = [ones(half,1);ones(half-1,1)*2];
        testLabel = 2;
    end;
    
    for base = 1:baseNo
        % 基底数までTrainとTestの定義
        Train = trainData(:,index(1:base));
        Test = testData(:,index(1:base));

        % Train用いて学習
        param = '-s 0 -t 0 -c 1';
        model = svmtrain(trainLabel,Train,param);
        
        % Testのラベル予測
        [predicted_label,accuracy,value] = svmpredict(testLabel,Test,model,'-b 0');
        
        if(predicted_label == testLabel)
            result(cnt,base) = 100;
        else
            result(cnt,base) = 0;
        end;
        toc;
    end;
    display(cnt)
end;
display(sprintf('threshold:%d',threshold));