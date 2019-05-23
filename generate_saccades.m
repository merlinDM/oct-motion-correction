function [ saccades ] = generate_saccades(timePeriod, ...
                                          saccadeLength, ...
                                          generatorTpe)
    if nargin < 3
            generatorTpe = 'ellipse';
    end
    
    if nargin < 2
        saccadeLength = 100;
    end
    
    if nargin < 1
        timePeriod = 1600;
    end
    
    if (saccadeLength * timePeriod <= 0) ...
            || saccadeLength < 0 ...
            || timePeriod    < 0
        msgID = 'OCT:BadArguments';
        msg   = 'Input arguments should be greater than zero';
        ex    = MException(msgID, msg);
        throw(ex);
    end
    
    switch generatorTpe
        case 'ellipse'
            generator = @generate_ellipse_velosities;
        case 'spiral'
            generator = @generate_spiral_velosities;
        case 'periodic'
            generator = @generate_periodic_velosities;
        otherwise
            msgID = 'OCT:BadArguments';
            msg   = 'Generator type should be one of ';
            msg   = msg + '[ellipse, spiral, periodic]';
            ex    = MException(msgID, msg);
            throw(ex);
    end
    
    saccadesNumber = ceil(timePeriod / saccadeLength);
    
    saccades_velocities = generator(saccadesNumber);
    saccades_lambda = generate_lambdas(saccadesNumber);

    saccades = [saccades_velocities saccades_lambda];

    saccadeConstants = [60 60 100];
    saccadeConstants = repmat(saccadeConstants, saccadesNumber, 1);

    saccades = array2table(saccades.*saccadeConstants, ...
        'VariableNames', {'vx', 'vy', 'lambda'});
end

function [ velocities ] = generate_periodic_velosities(saccadesNumber)
    vx = p_generate_periodic_velosities(saccadesNumber, 'x');
    vy = p_generate_periodic_velosities(saccadesNumber, 'y');
    velocities = [vx vy];
end

% 0.5..1.0
function [ velocities ] = p_generate_periodic_velosities(saccadesNumber, axis)

    if nargin < 2
        axis = 'x';
    end
    
    if axis == 'x'
        period = [1 -1  1 -1];
    elseif axis == 'y'
        period = [1  1 -1 -1];
    end
    
    periodSize = size(period, 2);
    N = ceil(saccadesNumber / periodSize) * periodSize;
    periods = repmat(period, 1, floor(N / periodSize))';
    
    randomVelocities = (rand(N, 1) + 1) / 2;
    periodicVelocities = randomVelocities .* periods;
    velocities = periodicVelocities(1:saccadesNumber);
end

% 0..4
function [ velocities ] = generate_spiral_velosities(saccadesNumber)
    a = 1; b = 1.1; c = 1/20;
    fx = @(t) a * exp(b * t) * sin((t - 1) / c);
    fy = @(t) a * exp(b * t) * cos((t - 1) / c);
    
    randomVelocities = rand(saccadesNumber, 1) / 2;

    vx = arrayfun(fx, randomVelocities);
    vy = arrayfun(fy, randomVelocities);
    spiralVelocities = [vx vy];

    velocities = spiralVelocities(1:saccadesNumber,:);
end

% 0.0..0.5
function [ velocities ] = generate_ellipse_velosities(saccadesNumber)
    a = 0.5; 
    e = 0.8;
    b = sqrt(a ^ 2 * (1 - e ^ 2));
    fx = @(t) a * sin(t - 1);
    fy = @(t) b * cos(t - 1);

    period = [1 -1];

    periodSize = size(period, 2);
    N = ceil(saccadesNumber / periodSize) * periodSize;
    periods = repmat(period, 1, floor(N / periodSize))';

    randomVelocities = rand(N, 1);

    % periodic [    pi / 2 ... 3 / 2 * pi] and 
    %          [3 / 2 * pi ... 5 / 2 * pi]
    periodicVelocities = randomVelocities .* periods * pi + 3 / 2 * pi;
    
    vx = arrayfun(fx, periodicVelocities);
    vy = arrayfun(fy, periodicVelocities);
    ellipseVelocities = [vx vy];

    velocities = ellipseVelocities(1:saccadesNumber,:);
end

% 0.8..0.9
function [ lambdas ] = generate_lambdas( saccadesNumber )
    lambdas = 1 - (rand(saccadesNumber, 1) + 1) / 10;
end
