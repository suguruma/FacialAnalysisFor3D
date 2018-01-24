% LocalFeatureClustering.m
% 2015/04/08
% �Ǐ�������k-means�g���ăN���X�^�����O����v���O����

clear all;
clc;
tic;

threshold = 90;
ClusterNum = 5;

% �f�[�^�̓ǂݍ���
MeanName = 'meanface.xls'; 
LocalName = 'LocalFeature_%d.xls';
MeanFace = xlsread(MeanName);
LocalFeature = xlsread(sprintf(LocalName,threshold));

% �Ǐ�������plot
figure;
plot3(MeanFace(:,1),MeanFace(:,2),MeanFace(:,3),'k.','MarkerSize',4);
hold on
plot3(LocalFeature(:,1),LocalFeature(:,2),LocalFeature(:,3),'b.','MarkerSize',4);
hold off

% k-means�̎���
% 1.�e�f�[�^�Ƀ����_���ɃN���X�^����U��
PointNum = size(LocalFeature,1);
RandomNum = rand(PointNum,1)*100;
Cluster = rem(round(RandomNum),ClusterNum) + 1;

display('step 1 �I��');
toc;

% 2.����U�����f�[�^����e�N���X�^���S���v�Z
Mean = zeros(ClusterNum,3);
num = zeros(ClusterNum,1);

for cnt = 1:PointNum
    
    for ClusterCnt = 1:ClusterNum
        if(ClusterCnt == Cluster(cnt,1))
            Mean(ClusterCnt,:) = Mean(ClusterCnt,:) + LocalFeature(cnt,:);
            num(ClusterCnt,1) = num(ClusterCnt,1) + 1;
        end;
    end;
end;

Mean = Mean ./ repmat(num,1,3);

Center = zeros(ClusterNum,1);


% ���߂��N���X�^���S�ɍł��߂��T���v����T��
Distance = zeros(max(num),2,ClusterNum);
num2 = zeros(ClusterNum,1);

for ClusterCnt = 1:ClusterNum
    for cnt = 1:PointNum
        if(ClusterCnt == Cluster(cnt,:))
            num2(ClusterCnt,1) = num2(ClusterCnt,1) + 1;
            dis = sqrt( ( Mean(ClusterCnt,1) - LocalFeature(cnt,1) )^2 + ( Mean(ClusterCnt,2) - LocalFeature(cnt,2) )^2 + ( Mean(ClusterCnt,3) - LocalFeature(cnt,3) ) ^2);
            Distance(num2(ClusterCnt,1),:,ClusterCnt) = [cnt dis];
        end;
    end;
end;

for ClusterCnt = 1:ClusterNum
    temp = find(Distance(:,2,ClusterCnt));
    [Value Index] = min(Distance(1:size(temp),:,ClusterCnt));
    Center(ClusterCnt,1) = Distance(Index(1,2),1,ClusterCnt);
end;

display('step 2 �I��');
toc;

CValue = [
    1 0 0;% red
    1 0.5 0; % orange;
    1 1 0; % yellow
    0.5 1 0; % right green
    0 1 0; % green
    0 0.8 1; % right blue
    0 0 1; % blue
    0.5 0 1; % purple
    1 0 0.5; % pink
    0.5 0.5 0.5; % gray
    ];


figure;
plot3(MeanFace(:,1),MeanFace(:,2),MeanFace(:,3),'k.','MarkerSize',4);
hold on
% �e�N���X�^�̐F���� 1:red,2:blue,3:green,4:m,5:c
for cnt = 1:PointNum
%     CValue = 0 + (1/(ClusterNum-1) * (Cluster(cnt,1) - 1));
    plot3(LocalFeature(cnt,1),LocalFeature(cnt,2),LocalFeature(cnt,3),'Marker','.','Color',CValue(Cluster(cnt,1),:));
    hold on;
end;

% �e�N���X�^���S
for ClusterCnt = 1:ClusterNum
%     CValue = 0 + ((1/(ClusterNum-1))* (ClusterCnt - 1));
    plot3(LocalFeature(Center(ClusterCnt,1),1),LocalFeature(Center(ClusterCnt,1),2),LocalFeature(Center(ClusterCnt,1),3),'Marker','s','Color',CValue(ClusterCnt,:),'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',CValue(ClusterCnt,:));
    hold on;
end;
hold off
display('plot(�����l)');
toc;

for loop = 1:100
    % 3-1.�N���X�^���S�Ƃ̋��������߂čŋߖT�̃N���X�^�Ɋ��蓖��
    NewDistance = zeros(ClusterNum,1); % Cluster
    NewCluster = zeros(PointNum,1); % Point�s
    for cnt = 1:PointNum
        for ClusterCnt = 1:ClusterNum
            dis = sqrt( ( LocalFeature(Center(ClusterCnt,1),1) - LocalFeature(cnt,1) )^2 + ( LocalFeature(Center(ClusterCnt,1),2) - LocalFeature(cnt,2) )^2 + ( LocalFeature(Center(ClusterCnt,1),3) - LocalFeature(cnt,3) ) ^2);
            NewDistance(ClusterCnt,:) = dis;
        end;
        [NearestCluster,ClusterIndex] = min(NewDistance);
        NewCluster(cnt,1) = ClusterIndex;
    end;

    display('step 3-1 �I��');

    % 3-2.����U�����f�[�^����e�N���X�^���S���v�Z
    NewMean = zeros(ClusterNum,3);
    num = zeros(ClusterNum,1);

    for cnt = 1:PointNum

        for ClusterCnt = 1:ClusterNum
            if(ClusterCnt == NewCluster(cnt,1))
                NewMean(ClusterCnt,:) = NewMean(ClusterCnt,:) + LocalFeature(cnt,:);
                num(ClusterCnt,1) = num(ClusterCnt,1) + 1;
            end;
        end;
    end;

    NewMean = NewMean ./ repmat(num,1,3);
    NewCenter = zeros(ClusterNum,1);


    % ���߂��N���X�^���S�ɍł��߂��T���v����T��
    NewDistance = zeros(max(num),2,ClusterNum);
    num2 = zeros(ClusterNum,1);

    for ClusterCnt = 1:ClusterNum
        for cnt = 1:PointNum
            if(ClusterCnt == NewCluster(cnt,:))
                num2(ClusterCnt,1) = num2(ClusterCnt,1) + 1;
                dis = sqrt( ( NewMean(ClusterCnt,1) - LocalFeature(cnt,1) )^2 + ( NewMean(ClusterCnt,2) - LocalFeature(cnt,2) )^2 + ( NewMean(ClusterCnt,3) - LocalFeature(cnt,3) ) ^2);
                NewDistance(num2(ClusterCnt,1),:,ClusterCnt) = [cnt dis];
            end;
        end;
    end;

    for ClusterCnt = 1:ClusterNum
        temp = find(NewDistance(:,2,ClusterCnt));
        [Value Index] = min(NewDistance(1:size(temp),:,ClusterCnt));
        NewCenter(ClusterCnt,1) = NewDistance(Index(1,2),1,ClusterCnt);
    end;

%     figure;
%     plot3(MeanFace(:,1),MeanFace(:,2),MeanFace(:,3),'k.','MarkerSize',4);
%     hold on
%     % �e�N���X�^�̐F���� 1:red,2:blue,3:green,4:m,5:c
%     for cnt = 1:PointNum
%         CValue = 0 + (1/(ClusterNum-1) * (NewCluster(cnt,1) - 1));
%         plot3(LocalFeature(cnt,1),LocalFeature(cnt,2),LocalFeature(cnt,3),'Marker','.','Color',[CValue 0 0]);
%         hold on;
%     end;
% 
%     % �e�N���X�^���S
%     for ClusterCnt = 1:ClusterNum
%         CValue = 0 + ((1/(ClusterNum-1))* (ClusterCnt - 1));
%         plot3(LocalFeature(NewCenter(ClusterCnt,1),1),LocalFeature(NewCenter(ClusterCnt,1),2),LocalFeature(NewCenter(ClusterCnt,1),3),'Marker','s','Color',[CValue 0 0],'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[CValue 0 0]);
%         hold on;
%     end;
%     hold off
% 

    display(sprintf('plot(%d���)',loop+1));
    toc;
end;

figure;
plot3(MeanFace(:,1),MeanFace(:,2),MeanFace(:,3),'k.','MarkerSize',4);
hold on
% �e�N���X�^�̐F���� 1:red,2:blue,3:green,4:m,5:c
for cnt = 1:PointNum
%     CValue = 0 + (1/(ClusterNum-1) * (NewCluster(cnt,1) - 1));
    plot3(LocalFeature(cnt,1),LocalFeature(cnt,2),LocalFeature(cnt,3),'Marker','.','Color',CValue(NewCluster(cnt,1),:));
    hold on;
end;
hold off;

% �e�N���X�^���S
for ClusterCnt = 1:ClusterNum
%     CValue = 0 + ((1/(ClusterNum-1))* (ClusterCnt - 1));
    plot3(LocalFeature(NewCenter(ClusterCnt,1),1),LocalFeature(NewCenter(ClusterCnt,1),2),LocalFeature(NewCenter(ClusterCnt,1),3),'Marker','s','Color',CValue(ClusterCnt,:),'MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',CValue(ClusterCnt,:));
    hold on;
end;
hold off

display('k-means �I��');

% �o��
xlswrite(sprintf('LF_Clustering_%d_%d.xls',threshold,ClusterNum),NewCluster);
xlswrite(sprintf('LF_Center_%d_%d.xls',threshold,ClusterNum),NewCenter);



