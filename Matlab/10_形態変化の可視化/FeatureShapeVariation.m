% FeatureShapeVariation.m
% 2016/01/13
% �`�ԕω����݂�
% ���͂̕������������������+3sigma,mean,-3sigma���o��

clear all;
clc;
tic;

feature = 'local';
database  = 1;
sample = 200;
first_num = 100;
second_num = 100;
sigma = 3;
meanshape = xlsread(sprintf('../ALLPCA/Output/mean_D%d_%s.xls',database,feature));
[pointNum dim] = size(meanshape);

coefs = xlsread(sprintf('../ALLPCA/Output/coefs_D%d_%s.xls',database,feature));
scores = xlsread(sprintf('../ALLPCA/Output/scores_D%d_%s.xls',database,feature));
variances = xlsread(sprintf('../ALLPCA/Output/variances_D%d_%s.xls',database,feature));
index = xlsread(sprintf('../ALLPCA/Output/index_D%d_%s.xls',database,feature));

base = index(1,1);
% base2 = index(2,1);
% base3 = index(3,1);

% reconst*****�͗�x�N�g���ɂ��Ă���
reconstMean = reshape(meanshape',pointNum*dim,1);
% ���U�l���߂�
reconst_var_m = sqrt(variances(base,1)) * -sigma;
reconst_var_p = sqrt(variances(base,1)) * sigma;


% �������߂ĕ��ςɑ���
reconst_m = reconstMean + reconst_var_m(1,1) * coefs(:,base);
reconst_p = reconstMean + reconst_var_p(1,1) * coefs(:,base);

% 3�����ɖ߂�
Morph_m = reshape(reconst_m',3,pointNum)';
Morph_p = reshape(reconst_p',3,pointNum)';

display('�v�Z�I��');

if(database == 1)
    markersize = 4;
else
    markersize = 5;
end;

% figure('Name','Global:meanshape');
% plot3(meanshape(:,1),meanshape(:,2),meanshape(:,3),'k.','MarkerSize',markersize);
% axis([0 140 -120 120 -120 80]);

figure('Name',sprintf('score : base %d ',base));
plot(1,scores(1:first_num,base),'b+');
hold on
plot(0,scores(first_num+1:sample,base),'ro');

% �I���������̃X�R�A�v���b�g
% figure('Name',sprintf('score : base %d & %d ',base,base2));
% plot(scores(1:first_num,base),scores(1:first_num,base2),'b+');
% hold on
% plot(scores(first_num+1:sample,base),scores(first_num+1:sample,base2),'ro');
% 
% figure('Name',sprintf('score : base %d & %d & %d ',base,base2,base3));
% plot3(scores(1:first_num,base),scores(1:first_num,base2),scores(1:first_num,base3),'b+');
% hold on
% plot3(scores(first_num+1:sample,base),scores(first_num+1:sample,base2),scores(first_num+1:sample,base3),'ro');

% �`�ԕω��̉���
figure('Name',sprintf('D%d)%s:-%dsigma',database,feature,sigma));
plot3(Morph_m(:,1),Morph_m(:,2),Morph_m(:,3),'k.','MarkerSize',markersize);
% hold on
axis([0 140 -120 120 -120 80]);

figure('Name',sprintf('D%d)%s:+%dsigma',database,feature,sigma));
plot3(Morph_p(:,1),Morph_p(:,2),Morph_p(:,3),'k.','MarkerSize',markersize);
axis([0 140 -120 120 -120 80]);

figure('Name',sprintf('D%d)%s:+-%dsigma',database,feature,sigma));
plot3(Morph_m(:,1),Morph_m(:,2),Morph_m(:,3),'b.','MarkerSize',markersize);
hold on
plot3(Morph_p(:,1),Morph_p(:,2),Morph_p(:,3),'r.','MarkerSize',markersize);
axis([0 140 -120 120 -120 80]);

