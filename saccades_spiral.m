% predictable seed
% randomGenerator = rng(2.5);
randomGenerator = rng;
saccadesNumber = 14;
parametersNumber = 4;

a = 1; b = 1.1; c = 1/20; lower = 1; upper = 2;
fx = @(t) a * exp(b * t) * sin((t - 1) / c); 
fy = @(t) a * exp(b * t) * cos((t - 1) / c) + 1;

saccades_vx = rand(saccadesNumber, 1);
saccades_vx = arrayfun(fx, saccades_vx);

saccades_vy = rand(saccadesNumber, 1);
saccades_vy = arrayfun(fx, saccades_vy);

saccades_lambda = 1 - (rand(saccadesNumber, 1) + 1) / 10;

saccades = [saccades_vx saccades_vy saccades_lambda];

saccadeConstants = [60 60 100];
saccadeConstants = repmat(saccadeConstants, saccadesNumber, 1);

saccades = array2table(saccades.*saccadeConstants, ...
    'VariableNames', {'vx', 'vy', 'lambda'})

i = 1;
timeFromStart = 0;
clear('origin');
origin(1).x = 1;
origin(1).y = 1;

for j = 1:saccadesNumber
    saccade = saccades(j,:);

    while i < saccadicPeriod + timeFromStart
        origin(i + 1).x = origin(i).x - saccade.vx / saccade.lambda ...
            * exp(-saccade.lambda * (i - timeFromStart));
        origin(i + 1).y = origin(i).y - saccade.vy / saccade.lambda * ...
            exp(-saccade.lambda * (i - timeFromStart));
        i = i + 1;
    end;
    timeFromStart = saccadicPeriod + timeFromStart;
    clear('saccade');
end;

figure;
sp1 = subplot(2,1,1);
plot([origin.x], [origin.y], '.-');
title('Origin movement on phase space - Multiple saccades');
grid(sp1,'on');

sp2 = subplot(2,1,2);
plot(1:(timeFromStart), sqrt([origin.x].^2 + [origin.y].^2));
title('Origin position on time - Multiple saccades');
grid(sp2,'on')