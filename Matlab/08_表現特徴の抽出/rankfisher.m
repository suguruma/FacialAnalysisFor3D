%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Culculation of degree of separation using in Discriminant Analysis---%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sortvec, indexvec] = rankfisher(featurevec, classnum)

%calculate degree of separation
dosvec = zeros(size(featurevec, 2), 1);
for i = 1:size(featurevec, 2)
    varIn = classnum(1) / size(featurevec, 1) * var(featurevec(1:classnum(1), i)) ... 
        + classnum(2) / size(featurevec, 1) * var(featurevec(classnum(1)+1:classnum(1)+classnum(2), i));
    varEx = classnum(1)*classnum(2) / size(featurevec, 1)^2 ... 
        * (mean(featurevec(1:classnum(1), i))-mean(featurevec(classnum(1)+1:classnum(1)+classnum(2), i)))^2;
    dosvec(i, 1) = varEx / varIn;
end;

%index
[sortvec, indexvec] = sort(dosvec, 'descend');

