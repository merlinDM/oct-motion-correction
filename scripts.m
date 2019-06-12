% V = urrd3;
% V = d3;
% V = acquiredImage;
V = distortedImage;
[MMAX, NMAX, PMAX] = size(V);
fps = 100;
pause off;
%%
for i = 1:10:MMAX
    I = squeeze(V(i,:,:));
    I = uint8(I);
    I = imresize(I, 10);
    disp(i)
    imshow(I)
    pause(1 / fps);
end
%%
for j = 1:10:NMAX
    I = squeeze(V(:,j,:));
    I = uint8(I);
    I = imresize(I, 10);
    disp(j)
    imshow(I)
    pause(1 / fps);
end
%%
for k = 1:2:PMAX
    I = squeeze(V(:,:,k));
    I = uint8(I);
    I = imresize(I, 10);
    imshow(I)
    title(k)
    pause(1 / fps);
end
%%
load('C:\Users\lenovo\Documents\MATLAB\patient#1\1_left.mat', 'd3')
import thirdparty.pyramid.*
rd3 = GPReduce(d3);
rrd3 = GPReduce(rd3);
urrd3 = uint8(rrd3);
%%
experimentIndex = 5;
experimentSize = 2;
experimentData = 'urrd3';

s = ScannigProcedure();
s.rawImage = urrd3;
s.saccadesAmplitude = 7;
s.saccadesPerImage = 4;
s.saveExperimentData(experimentIndex, experimentSize, 'urrd3');

p = RegistrationProcedure();
p.transformationMode = 'rigid';
[registered, raw, scores] = p.registerExperiment(experimentIndex);

disp(scores);