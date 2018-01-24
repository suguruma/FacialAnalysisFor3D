% program/���/LocalFeature
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
    % �f�[�^�̓ǂݍ���
    trainScore = xlsread(sprintf(TrainName,threshold,cnt));
    testScore = xlsread(sprintf(TestName,threshold,cnt));
%     �ŗL�l��
%     index = 1:baseNo;
%     �t�B�b�V���[�X�R�A��
    index = xlsread(sprintf(indexName,threshold,cnt));
    
%     ���K������Ƃ��͎g��
%     var = xlsread(sprintf(varName,threshold,cnt));
%     variance = sqrt(var)/100;
%     variance = sqrt(var);
    
%     trainScore = trainScore / 100;
%     testScore = testScore / 100;

    %     ���K���Ȃ�
%     trainData = trainScore;
%     testData = testScore;
%     
    % ���K��1
    max_value = max(trainScore,[],1);
    min_value = min(trainScore,[],1);
    diff = max_value - min_value;
    
    trainData = (trainScore - repmat(min_value,sample-1,1)) ./ repmat(diff,sample-1,1);
    testData = (testScore - min_value) ./ diff;
    
%     ���K��2
%     trainData = trainScore ./ repmat(variance',sample-1,1);
%     testData = testScore ./ variance';
    
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
display(sprintf('threshold:%d',threshold));