% program/�O��/DataSampling
% DataSamplingSVM.m
% 2015/06/02

clear all;
clc;
tic;

sample = 200;
half = sample / 2;
baseNo = sample - 2;
IndexSize = 5621;

TrainName = 'TrainPCA/%d/scores_%d_%d.xls';
TestName = 'TestPCA/%d/testscores_%d_%d.xls';
indexName = 'TrainPCA/%d/index_%d_%d.xls';
varName = 'TrainPCA/%d/variances_%d_%d.xls';

result = zeros(sample,baseNo);
for cnt = 1:sample
    % �f�[�^�̓ǂݍ���
    trainScore = xlsread(sprintf(TrainName,IndexSize,IndexSize,cnt));
    testScore = xlsread(sprintf(TestName,IndexSize,IndexSize,cnt));
%     �ŗL�l��
    index = [1:baseNo]';
%     �t�B�b�V���[�X�R�A��
    index = xlsread(sprintf(indexName,IndexSize,IndexSize,cnt));
    
%     trainScore = trainScore / 100;
%     testScore = testScore / 100;

%     %     ���K���Ȃ�
%     trainData = trainScore;
%     testData = testScore;

%     ���K��1
    max_value = max(trainScore,[],1);
    min_value = min(trainScore,[],1);
    diff = max_value - min_value;
    
    trainData = (trainScore - repmat(min_value,sample-1,1)) ./ repmat(diff,sample-1,1);
    testData = (testScore - min_value) ./ diff;
    
    
    % ���x���t��
    if(cnt <= half) % test:om
        trainLabel = [ones(half-1,1);ones(half,1)*2];
        testLabel = 1;
    else % test:hm
        trainLabel = [ones(half,1);ones(half-1,1)*2];
        testLabel = 2;
    end;
    
    for base = 1:baseNo
        % ��ꐔ�܂�Train��Test�̒�`
        Train = trainData(:,index(1:base));
        Test = testData(:,index(1:base));

        % Train�p���Ċw�K
        param = '-s 0 -t 0 -c 1';
        model = svmtrain(trainLabel,Train,param);
        
        % Test�̃��x���\��
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


% display(num);