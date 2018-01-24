%�ǂ݂Ƃ����f�[�^�̎��̐���
%�`.stl��x,y,z���̏��ԂƂ����ǂݏo�����`vertex.xls��x,y,z���̏��Ԃ͒����I�ɗ������ɂ������߁A���Ԃ����ւ���

%������-------------------------------------
clear all
clc;
tic;

%the number of sample
sample = 885;

for dn = 1:sample
    %�f�[�^����-----------------
    openData_raw = sprintf('3DData/data%d.xls', dn);
    saveface_raw = sprintf('3DData_ChangeAxis/data%d.xls', dn);
    
    fp = fopen(openData_raw);
    
    if(fp == -1)
        clear fp
    else
        data_temp = xlsread(openData_raw);

        message = sprintf('File open ... %d',dn);
        display(message);

        %���ԓ���ւ�
        data_raw(:, 1) = data_temp(:, 3);
        data_raw(:, 2) = data_temp(:, 1);
        data_raw(:, 3) = data_temp(:, 2);

        %�ۑ�
        xlswrite(saveface_raw, data_raw);
        fclose(fp);
    end;
    clear data_temp data_raw
end;

toc;
display('All processing is done.');
clear dn sample