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

%%
a = 0.5; b = 0.1; c = 1 / pi;
fx = @(t) a * exp(b * (t - 2)) * sin((t - 2) / c);
fy = @(t) a * exp(b * (t - 2)) * cos((t - 2) / c);
fplot(fx, fy, [-1 1])
grid on

%%
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
%|==B-scan==|==B-scan==|==...==|==B-scan==|
% /\||/\||/\ ||/\||/\||         ||/\||/\||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% |||||||||| ||||||||||         ||||||||||
% ||\/||\/|| \/||\/||\/         \/||\/||\/