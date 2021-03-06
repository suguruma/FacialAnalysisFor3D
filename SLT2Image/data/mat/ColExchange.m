%読みとったデータの軸の整理
%〜.stlのx,y,z軸の順番とそれを読み出した〜vertex.xlsのx,y,z軸の順番は直感的に理解しにくいため、順番を入れ替える

%初期化-------------------------------------
clear all
clc;
tic;

%the number of sample
sample = 2;

for dn = 1:sample
    %データ入力-----------------
    openData_raw = sprintf('readData/hmvertex%d.xls', dn);
    saveface_raw = sprintf('hmvertex_c%d.xls', dn);
    data_temp = xlsread(openData_raw);
    
    display('File open ...');
    
    %順番入れ替え
    data_raw(:, 1) = data_temp(:, 3);
    data_raw(:, 2) = data_temp(:, 1);
    data_raw(:, 3) = data_temp(:, 2);

    %保存
    xlswrite(saveface_raw, data_raw);
    
    clear data_temp data_raw
end;

toc;
display('All processing is done.');
clear dn sample