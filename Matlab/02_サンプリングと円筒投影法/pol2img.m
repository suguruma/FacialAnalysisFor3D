%sampling data to img
%‰~“›À•WŒn‚ÌŠçŒ`óƒf[ƒ^‚ğ2ŸŒ³‚Ì”Z’W‰æ‘œ‚É•ÏŠ·‚·‚é

%initialize--------------------------------------
clear all
clc;
tic;

sample = 200;
half = sample / 2;

%sampling size
v = 400;
h = 360;

%read data
for dn = 1:half
%     facedata = sprintf('polData/hmsample%d.xls',dn);
%     writeName = sprintf('2DImg/hmImage%d.jpg',dn);
    
    facedata = sprintf('polData/omsample%d.xls',dn);
    writeName = sprintf('2DImg/omImage%d.jpg',dn);
    
    dataset = xlsread(facedata);

    %to image
    rho = reshape(dataset(:, 2), h, v)';
    rho = flipud(rho);
    rho(isnan(rho)) = 0;

    diff = max(rho(:)) - min(rho(:));
    rho2 = rho / diff;
    %display
%     figure;imshow(rho,[]);% title('img');
%     figure;imshow(rho2,[]);% title('img');
    imwrite(rho2,writeName);
toc;
end;