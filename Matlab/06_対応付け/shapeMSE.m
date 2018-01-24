function [sumVec, value] = shapeMSE(baseVec, targetVec)
%MSE�̌v�Z�p�֐�

%�`��Ԃ̓��덷���v�Z-----------------------
mseVec = baseVec - targetVec;
mseVec = mseVec.^2;
sumVec = sum(mseVec, 2);
value = sqrt(sum(sumVec) / length(sumVec));

clear mseVec