%% Compare different approaches to generate saccades

predictableSeed = 1.5;
randomGenerator = rng(predictableSeed);

timePeriod = 4000;
saccadeLength = 200;
limit = 2;

saccades = generateSaccades(timePeriod, saccadeLength, 'periodic');
origin = originMovement(saccades, saccadeLength);
% sp = subplot(3,1,1);
plot([origin.x], [origin.y], '.--');
hold on
grid on
xlabel('x')
ylabel('y')

saccades = generateSaccades(timePeriod, saccadeLength, 'spiral');
origin = originMovement(saccades, saccadeLength);
plot([origin.x], [origin.y], 'o-');

saccades = generateSaccades(timePeriod, saccadeLength, 'ellipse');
origin = originMovement(saccades, saccadeLength);
plot([origin.x], [origin.y], 'x-');
hold off

%% Apply generated saccades to 3D image
import thirdparty.phantom3d.*

NMAX = 30;
NMIN = 1;
fps = 10;

phantomImage = phantom3d('shepp-logan', NMAX);

m = NMAX; n = NMAX; p = NMAX;

% predictableSeed = 1.5;
% randomGenerator = rng(predictableSeed);
randomGenerator = rng;

saccadeLength = 100;

saccades = generateSaccades(m * n, saccadeLength);
origin = originMovement(saccades, saccadeLength);
Dxfast = displacementField3d(origin, m, n, p, 'xfast');
Dyfast = displacementField3d(origin, m, n, p, 'yfast');

acquiredImageXFast = imwarp(phantomImage, Dxfast);
acquiredImageYFast = imwarp(phantomImage, Dyfast);

figure;
for y = 1:100
    pause(1/fps);
    subplot(2,1,1);
    slice(acquiredImageXFast, ...
     (NMAX), (mod(y, NMAX) + 1), (NMIN))
    subplot(2,1,2);
    slice(acquiredImageYFast, ...
     (NMAX), (mod(y, NMAX) + 1), (NMIN))
end

%% logarythmic spiral
a = 0.5; b = 0.1; c = 1 / pi;
fx = @(t) a * exp(b * (t - 2)) * sin((t - 2) / c);
fy = @(t) a * exp(b * (t - 2)) * cos((t - 2) / c);
fplot(fx, fy, [-1 1])
grid on

%% check image quality metric 
clear;

fps = 10;
pause on;

p = 5;
rows = 10;
n = rows * p * 2;
m = rows * p * 2;
I = checkerboard(p, rows);
I_ref = imref2d(size(I));
bg = zeros(size(I) * 2);
bg_ref = imref2d(size(bg));
[I_bg, I_bg_ref] = imfuse(I, I_ref, bg, bg_ref);

step = 1;
len = floor(size(I, 1) / step);
err = struct('x',    cell(1, len), ... 
             'mse',  cell(1, len), ...
             'niqe', cell(1, len), ...
             'piqe', cell(1, len), ...
             'brisque', cell(1, len), ...
             'ssim', cell(1, len));

for x=1:step:size(I)
    T = [1 0 0; 0 1 0; x x 1];
    tform = affine2d(T);
    [J, J_ref] = imwarp(I, I_ref, tform);
    J_bg = imfuse(J, J_ref, bg, bg_ref);
    err(floor(x / step) + 1).x = x;
    err(floor(x / step) + 1).mse = log(immse(I_bg, J_bg));
    err(floor(x / step) + 1).brisque = log(brisque(J_bg));
    err(floor(x / step) + 1).niqe = log(niqe(J_bg));
    err(floor(x / step) + 1).piqe = log(piqe(J_bg));
    err(floor(x / step) + 1).ssim = ssim(I_bg, J_bg);
%     imshow(J_bg);
%     pause(1/fps);
end

plot([err.x], [err.mse]);
title('')
ylabel('значение метрики')
xlabel('сдвиг')
hold on;
grid on;
plot([err.x], [err.ssim]);
plot([err.x], [err.brisque]);
plot([err.x], [err.niqe]);
plot([err.x], [err.piqe]);
legend('mse (log)', 'ssim', 'brisque (log)', 'niqe (log)', 'piqe');
hold off;

%% Scanning pattern. I hope that could be usefull someday
%|==B-scan==|==B-scan==|==...==|==B-scan==|
% /\||/\||/\ ||/\||/\||         ||/\||/\||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% ||\/||\/|| \/||\/||\/         \/||\/||\/

%% Experiment 1: Save distorted images as resources

experiment.index = 1;
experiment.size = 10;
experiment.dir = sprintf('%s\\resources\\experiment_%02d', pwd, experiment.index);
experiment.prefix = 'checkerboard';
experiment.namesFormat = strcat(experiment.prefix, '_%02d_%s.mat');
experiment.dims = '2d';

experiment.pixels = 10;
experiment.rows = 10;
experiment.columns = 10;
n = experiment.rows * experiment.pixels * 2;
m = experiment.rows * experiment.pixels * 2;
originalImage = checkerboard(experiment.pixels, experiment.rows, experiment.columns);

experiment.saccadeLength = m * n / 2;

save(strcat(experiment.dir, '\', sprintf(experiment.namesFormat, 0, 'raw')), 'originalImage');

for i = 1:experiment.size
    direction = 'xfast';
    if rem(i, 2) == 1
        direction = 'yfast';
    end
    
    saccades = generateSaccades(m * n, experiment.saccadeLength);
    origin = originMovement(saccades, experiment.saccadeLength);

    D = displacementField2d(origin, m, n, direction);
    distortedImage = imwarp(originalImage, D);

    filepath = strcat(experiment.dir, '\', sprintf(experiment.namesFormat, i, direction));

    save(filepath, 'distortedImage');
end

filepath = strcat(experiment.dir, '\', 'meta.mat');
save(filepath, 'experiment');

%%  Experiment 2: Save distorted phantom as resources
experiment.index = 2;
experiment.size = 10;
experiment.dir = sprintf('%s\\resources\\experiment_%02d', pwd, experiment.index);
mkdir(experiment.dir);
experiment.prefix = 'phantom';
experiment.namesFormat = strcat(experiment.prefix, '_%02d_%s.mat');
experiment.dims = '3d';

import thirdparty.phantom3d.*

experiment.volSize = 30;
m = experiment.volSize; 
n = experiment.volSize; 
p = experiment.volSize;
experiment.saccadeLength = m * n / 2;

phantomImage = phantom3d('shepp-logan', experiment.volSize);

save(strcat(experiment.dir, '\', sprintf(experiment.namesFormat, 0, 'raw')), 'phantomImage');

for i = 1:experiment.size
    direction = 'xfast';
    if rem(i, 2) == 1
        direction = 'yfast';
    end
    
    saccades = generateSaccades(m * n, experiment.saccadeLength);
    origin = originMovement(saccades, experiment.saccadeLength);
    z_movement = zeros(m * n, 1)';

    D = displacementField3d(origin, m, n, p, direction);
    distortedImage = imwarp(phantomImage, D);

    filepath = strcat(experiment.dir, '\', sprintf(experiment.namesFormat, i, direction));

    save(filepath, 'distortedImage');
end

filepath = strcat(experiment.dir, '\', 'meta.mat');
save(filepath, 'experiment');
%%  Experiment 1.1: save experiment 1 as jpg
experiment.index = 3;
experiment.size = 10;
experiment.dir = sprintf('%s\\resources\\experiment_%02d', pwd, experiment.index);
mkdir(experiment.dir);
experiment.prefix = 'checkerboard';
experiment.namesFormat = strcat(experiment.prefix, '_%02d_%s.jpg');
experiment.dims = '2d';

experiment.pixels = 10;
experiment.rows = 10;
experiment.columns = 10;
n = experiment.rows * experiment.pixels * 2;
m = experiment.rows * experiment.pixels * 2;
originalImage = checkerboard(experiment.pixels, experiment.rows, experiment.columns);

experiment.saccadeLength = m * n / 2;

imwrite(originalImage, strcat(experiment.dir, '\', sprintf(experiment.namesFormat, 0, 'raw')));

for i = 1:experiment.size
    direction = 'xfast';
    if rem(i, 2) == 1
        direction = 'yfast';
    end
    
    saccades = generateSaccades(m * n, experiment.saccadeLength);
    origin = originMovement(saccades, experiment.saccadeLength);

    D = displacementField2d(origin, m, n, direction);
    distortedImage = imwarp(originalImage, D);

    filepath = strcat(experiment.dir, '\', sprintf(experiment.namesFormat, i, direction));

    imwrite(distortedImage, filepath);
end

filepath = strcat(experiment.dir, '\', 'meta.mat');
save(filepath, 'experiment');
%% Autogenerated code for imregister function
optimizer = registration.optimizer.RegularStepGradientDescent();
metric = registration.metric.MeanSquares();
%
% Modifications to optimizer/metric
optimizer.GradientMagnitudeTolerance = 0.000100;
optimizer.MinimumStepLength = 0.000010;
optimizer.MaximumStepLength = 0.062500;
optimizer.MaximumIterations = 100;
optimizer.RelaxationFactor = 0.500000;
%
TForm = imregtform(Moving,Fixed,'Rigid',optimizer,metric,'DisplayOptimization',1,'PyramidLevels',3);
if size(Fixed,3)==1
	Rfixed = imref2d(size(Fixed));
else
	Rfixed = imref3d(size(Fixed));
end
[registered,SRI] = imwarp(Moving,TForm,'OutputView',Rfixed);
%
%OR:%
[registered,SRI] = imregister(Moving,Fixed,'Rigid',optimizer,metric,'DisplayOptimization',1,'PyramidLevels',3);

%imshowpair(fixed,registered);

%%  How to filter those damn structs 
% Solution from 
% https://stackoverflow.com/questions/24574408/matlab-filter-struct-array-using-multiple-strings
selectedTpe = {'raw'}; 
selectedIndex = cellfun(@(x) any(strcmp(x, selectedTpe)), {data.tpe});
selectedData = data(selectedIndex);
%%
