function [sumVec, value] = shapeMSE(baseVec, targetVec)
%MSEÌvZpÖ

%`óÔÌñæë·ðvZ-----------------------
mseVec = baseVec - targetVec;
mseVec = mseVec.^2;
sumVec = sum(mseVec, 2);
value = sqrt(sum(sumVec) / length(sumVec));

clear mseVec