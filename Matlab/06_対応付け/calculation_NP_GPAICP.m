%対応点の計算と決定
%点間の距離判定を行い、最近傍点を対応点に決定する
%GPAまたはICPの場合

%Initialize----------------------------------------------------------------
clear all
clc;
tic;

%Set parameter-------------------------------------------------------------
sample = 200;
landNo = 17;

%GPAのとき
inLand = 'alignLand/alignland%d.xls';
inVec = 'moveData/aligntrim_move%d.xls';
outFile = 'indexData/aligntrim_index%d.xls';

%Calculate mean landmark shape---------------------------------------------
landmark{sample} = [];
meandata = zeros(landNo, 3);
for i = 1:sample
    openLand = sprintf(inLand, i);
    landmark{i} = xlsread(openLand);
    meandata = meandata + landmark{i};
end;
meandata = meandata / sample;
display('Mean landmark has been calculated ...');

%Calculate nearest landmark------------------------------------------------
minvalue = 100;
minland = 0;
for i = 1:sample
    [sumVec, value] = shapeMSE(meandata, landmark{i});
    if minvalue > value
        minvalue = value;
        minland = i;
    end;
end;
clear landmark

%Read base dataset---------------------------------------------------------
baseVec = sprintf(inVec, minland);
datasetB = xlsread(baseVec);

%First correspondence------------------------------------------------------
datasetM{sample} = [];
corresmat{sample} = [];
for dn = 1:sample
    %Read each dataset-------------------------------------------------
    resampleM = sprintf(inVec, dn);
    datasetM{dn} = xlsread(resampleM);
    corresvec = zeros(size(datasetB, 1), 1);

    %Calculate nearest point-------------------------------------------
    for i = 1:size(datasetB, 1)
        for dim = 1:3
            dismat1(:, dim) = datasetM{dn}(:, dim) - datasetB(i, dim);
        end;
        dismat1 = dismat1.^2;
        dismat2 = sum(dismat1, 2);

        %Determine corresponding point---------------------------------
        [minVal, minIndex] = min(dismat2);
        corresvec(i) = minIndex;
    end;
    fprintf('dn:%d\n',dn);
    %Keep index--------------------------------------------------------
    corresmat{dn} = corresvec;
   
    clear resampleM saveIndex dismat1 dismat2
end;
display('First correspondence is over.');

%Update base dataset---------------------------------------------------
meandata = zeros(size(datasetB, 1), 3);
for i = 1:sample
    meandata = meandata + datasetM{i}(corresmat{i}(:), :);
end;
meandata = meandata / sample;
display('Mean shape has been calculated ...');

%Correspondent to meanshape--------------------------------------------
for dn = 1:sample
    %Read each dataset-------------------------------------------------
    corresvec = zeros(size(meandata, 1), 1);

    %Calculate nearest point-------------------------------------------
    for i = 1:size(meandata, 1)
        for dim = 1:3
            dismat1(:, dim) = datasetM{dn}(:, dim) - meandata(i, dim);
        end;
        dismat1 = dismat1.^2;
        dismat2 = sum(dismat1, 2);

        %Determine corresponding point---------------------------------
        [minVal, minIndex] = min(dismat2);
        corresvec(i) = minIndex;
    end;

    %Save index--------------------------------------------------------
    saveIndex = sprintf(outFile, dn);
    xlswrite(saveIndex, corresvec);
    fprintf('dn:%d\n',dn);
    clear dismat1 dismat2
end;
display('Fine correspondence is over.');

toc;
clear sample landNo dn i value inLand inVec outFile