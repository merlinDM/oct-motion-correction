function [ saccades ] = generate_saccades(timePeriod, saccadeLength)

    switch nargin
        case 1
            saccadeLength = 100;
        case 0
            saccadeLength = 100;
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
    
    requiredSaccadesNumber = ceil(timePeriod / saccadeLength);
    saccadesNumber = ceil(requiredSaccadesNumber / 4) * 4;
    
    saccades_vx = (rand(saccadesNumber, 1) + 1) / 2;
    saccades_vx = saccades_vx.*repmat([1 -1  1 -1], 1, floor(saccadesNumber / 4))';

    saccades_vy = (rand(saccadesNumber, 1) + 1) / 2;
    saccades_vy = saccades_vy.*repmat([1  1 -1 -1], 1, floor(saccadesNumber / 4))';

    saccades_lambda = 1 - (rand(saccadesNumber, 1) + 1) / 10;

    saccades = [saccades_vx saccades_vy saccades_lambda];

    saccadeConstants = [60 60 100];
    saccadeConstants = repmat(saccadeConstants, saccadesNumber, 1);

    saccades = array2table(saccades.*saccadeConstants, ...
        'VariableNames', {'vx', 'vy', 'lambda'});

    saccades = saccades(1:requiredSaccadesNumber,:);
end

