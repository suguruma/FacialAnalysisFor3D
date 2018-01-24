%TPSによる非剛体変形を用いた顔形状データの変形
%特徴点を利用し、TPSに基づいた非剛体変形により顔形状データを変形する
%GPAのとき

%Initialize----------------------------------------------------------------
clear all
clc;
tic;

%Set parameter-------------------------------------------------------------
sample = 200;
landNo = 17;

%GPAのとき
inLand = 'alignLand/alignland%d.xls';
inVec = 'trimData/trimdata%d.xls';
outFile = 'moveData/aligntrim_move%d.xls';

%Calculate mean landmark shape--------------------------------------------
landmark{sample} = [];
meandata = zeros(landNo, 3);
target = zeros(landNo+4, 3);
for i = 1:sample
    openLand = sprintf(inLand, i);
    landmark{i} = xlsread(openLand);
    meandata = meandata + landmark{i};
end;
meandata = meandata / sample;
target(1:landNo, :) = meandata;
display('Mean shape has been calculated ...');
clear landmark

%Iteration-----------------------------------------------------------------
for dn = 1:sample
    %Read each landmark data-----------------------------------------------
    moveLand = sprintf(inLand, dn);
    landmark_move = xlsread(moveLand);
    display('File open ...');
    fprintf('data%d\n', dn);
    
    %Calculate weight matrix-----------------------------------------------
    K = zeros(landNo, landNo);
    Q = zeros(landNo, 4);
    L = zeros(landNo+4, landNo+4);
    for i = 1:landNo
        for j = 1:landNo
            K(i, j) = norm(landmark_move(i, :) - landmark_move(j, :));
        end;
    end;
    Q(:, 1) = 1;
    Q(:,2:4) = landmark_move;
    L(1:landNo, 1:landNo+4) = horzcat(K, Q);
    L(landNo+1:landNo+4, 1:landNo) = Q';
    Weight = (inv(L) * target)';

    %Calculate RBF & Non-ligid Alignment-----------------------------------
    moveMesh = sprintf(inVec, dn);
    mesh_move = xlsread(moveMesh);
    mesh_new = zeros(size(mesh_move, 1), 3);   
    for j = 1:size(mesh_move, 1)
        RBF = zeros(landNo+4, 1);
        for i = 1:landNo
            RBF(i, 1) = norm(mesh_move(j, :) - landmark_move(i, :));
        end;
        RBF(landNo+1, 1) = 1;
        RBF(landNo+2:landNo+4, 1) = mesh_move(j, :)';
        mesh_new(j, :) = (Weight * RBF)';
    end;

    %Display---------------------------------------------------------------
%     figure;
%     plot3(meandata(:, 1), meandata(:, 2), meandata(:, 3), 'or', 'MarkerSize', 9);
%     hold on
%     plot3(landmark_move(:, 1), landmark_move(:, 2), landmark_move(:, 3), '.m', 'MarkerSize', 16);
%     plot3(mesh_move(:, 1), mesh_move(:, 2), mesh_move(:, 3), '.c', 'MarkerSize', 1);
%     plot3(mesh_new(:, 1), mesh_new(:, 2), mesh_new(:, 3), 'xb', 'MarkerSize', 1);
%     hold off
    
    %save------------------------------------------------------------------
    saveface = sprintf(outFile, dn);
    xlswrite(saveface, mesh_new);
    clear mesh_move mesh_new landmark_move
end;

toc;
clear landNo i j sample inLand inVec meandata
clear moveLand moveMesh openLand dn