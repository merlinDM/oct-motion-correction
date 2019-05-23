%% Compare different approaches to generate saccades

predictableSeed = 1.5;
randomGenerator = rng(predictableSeed);

timePeriod = 3000;
saccadeLength = 100;
limit = 1;

generate_saccades(timePeriod, saccadeLength, 'periodic');
generate_saccades(timePeriod, saccadeLength, 'ellipse');
generate_saccades(timePeriod, saccadeLength, 'spiral');

saccades = generate_saccades(timePeriod, saccadeLength, 'periodic');
origin = origin_movement(saccades, saccadeLength);
sp = subplot(3,1,1);
plot([origin.x], [origin.y], '.-');
hold on
plot( limit, -limit);
plot(-limit,  limit)
hold off
grid(sp,'on');
title('periodic');

saccades = generate_saccades(timePeriod, saccadeLength, 'spiral');
origin = origin_movement(saccades, saccadeLength);
sp = subplot(3,1,2);
plot([origin.x], [origin.y], '.-');
hold on
plot( limit, -limit);
plot(-limit,  limit)
hold off
grid(sp,'on');
title('spiral');

saccades = generate_saccades(timePeriod, saccadeLength, 'ellipse');
origin = origin_movement(saccades, saccadeLength);
sp = subplot(3,1,3);
plot([origin.x], [origin.y], '.-');
hold on
plot( limit, -limit);
plot(-limit,  limit)
hold off
grid(sp,'on');
title('ellipse, e = 0.6');

%% Apply generated saccades to 3D image
import 3rdparty.phantom3d.*

NMAX = 30;
NMIN = 1;
fps = 10;

phantomImage = phantom3d('shepp-logan', NMAX);

m = NMAX; n = NMAX; p = NMAX;

% predictableSeed = 1.5;
% randomGenerator = rng(predictableSeed);
randomGenerator = rng;

saccadeLength = 100;

saccades = generate_saccades(m * n, saccadeLength);
origin = origin_movement(saccades, saccadeLength);
Dxfast = displacement_field_3d(origin, m , n, p, 'xfast');
Dyfast = displacement_field_3d(origin, m , n, p, 'yfast');

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
end;