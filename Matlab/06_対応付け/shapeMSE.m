function [sumVec, value] = shapeMSE(baseVec, targetVec)
%MSEの計算用関数

%形状間の二乗誤差を計算-----------------------
mseVec = baseVec - targetVec;
mseVec = mseVec.^2;
sumVec = sum(mseVec, 2);
value = sqrt(sum(sumVec) / length(sumVec));

clear mseVec