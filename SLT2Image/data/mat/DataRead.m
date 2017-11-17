%stlデータの読み出し
%実行時間短縮のために、stlデータを読み出し、xlsファイルとして保存する

%initialize
clear all
clc;
tic;

%input & output 
inName = 'rawData/om%d.stl';
outName = 'omvertex%d.xls';

%the number of sample
sample = 2;

%read dataset--------------------------------------------------------------
for Num = 1:sample,
    facedata = sprintf(inName, Num);
    fp1 = fopen(facedata);
    display('File open ...');

    %ファイルをロードする--------------------------------------------------------
    fgets(fp1); %最初の1行をスキップ
    readStl = fscanf(fp1, '%s %s %f %f %f\n%s %s\n%s %f %f %f\n%s %f %f %f\n%s %f %f %f\n%s\n%s');
    Stlsize = size(readStl);
    readStl(Stlsize(1)-11:Stlsize(1), :) = []; %最後の1行分を削除

    %頂点座標のみの行列を生成----------------------------------------------------
    %65行で1セット　うち，65n+12～14が法線ベクトル→，65n+30～32，65n+39～41，65n+48～50が頂点
    Stlsize = size(readStl);
    for i = 0:(Stlsize(1)/65-1)
        vertex1(3*i+1:3*i+3, :) = readStl(65*i+30:65*i+32, :);
        vertex2(3*i+1:3*i+3, :) = readStl(65*i+39:65*i+41, :);
        vertex3(3*i+1:3*i+3, :) = readStl(65*i+48:65*i+50, :);
    end;
    
    %転置
    vertex1 = reshape(vertex1, 3, Stlsize(1)/65)';
    vertex2 = reshape(vertex2, 3, Stlsize(1)/65)';
    vertex3 = reshape(vertex3, 3, Stlsize(1)/65)';
    
    %連結
    vertexAll = vertcat(vertex1, vertex2, vertex3);
    dataset = unique(vertexAll, 'rows');

    clear readStl
    display('"face vertex" information memory load done...');

    %save sampling data--------------------------------------------------------
    saveface = sprintf(outName, Num);
    xlswrite(saveface, dataset)
    clear vertex1 vertex2 vertex3 vertexAll dataset facedata saveface;
end;

toc;
display('All processing is done.');

%free memory-------------------------------------------------------------------
clear inName outName Num sample
