%�ǂ݂Ƃ����f�[�^�̎��̐���
%�`.stl��x,y,z���̏��ԂƂ����ǂݏo�����`vertex.xls��x,y,z���̏��Ԃ͒����I�ɗ������ɂ������߁A���Ԃ����ւ���

%������-------------------------------------
clear all
clc;
tic;

%the number of sample
sample = 2;

for dn = 1:sample
    %�f�[�^����-----------------
    openData_raw = sprintf('readData/hmvertex%d.xls', dn);
    saveface_raw = sprintf('hmvertex_c%d.xls', dn);
    data_temp = xlsread(openData_raw);
    
    display('File open ...');
    
    %���ԓ���ւ�
    data_raw(:, 1) = data_temp(:, 3);
    data_raw(:, 2) = data_temp(:, 1);
    data_raw(:, 3) = data_temp(:, 2);

    %�ۑ�
    xlswrite(saveface_raw, data_raw);
    
    clear data_temp data_raw
end;

toc;
display('All processing is done.');
clear dn sample