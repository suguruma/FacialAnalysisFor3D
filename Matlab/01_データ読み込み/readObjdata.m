% M2/program/Data
% readObjdata.m
% 2015/04/29
% objデータを読み込んで点群データに変換
% xlsファイルとして出力

clear all;
clc;
tic;

% 元データ
inName = 'objData/R%d.obj';
outName = '3DData/data%d.xls';

sample = 885;

for samplenum = 1:sample
    facedata = sprintf(inName,samplenum);
    fp = fopen(facedata);

    if(fp == -1)
        clear fp;
    else
        display(samplenum);
        
        line1 = fgets(fp);
        line2 = fgets(fp);
        line3 = fgets(fp);

        readObj= fscanf(fp,'%s %f %f %f');
        Objsize = size(readObj);
        readObj(Objsize(1,1),:) = [];

        Datasize = (Objsize(1,1)-1) / 4;
        Outsize = 0;
        readData = zeros(Datasize,3);
        for cnt = 1:Datasize
            if(readObj(4*(cnt-1)+1,1) == 118)
                readData(cnt,1) = readObj(4*(cnt-1)+2,1);
                readData(cnt,2) = readObj(4*(cnt-1)+3,1);
                readData(cnt,3) = readObj(4*(cnt-1)+4,1);
                Outsize = cnt;
            end;
        end;

        OutData = zeros(Outsize,3);
        OutData(:,:) = readData(1:Outsize,:);

        xlswrite(sprintf(outName,samplenum),OutData);
        fclose(fp);

    end;
    toc;
end;

toc;
