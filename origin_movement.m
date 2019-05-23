function [ origin ] = origin_movement(saccades, saccadeLength)

    if nargin == 1
        saccadeLength = 100;
    elseif nargin == 0
        msgID = 'OCT:BadArguments';
        msg   = 'Not enough arguments';
        ex    = MException(msgID, msg);
        throw(ex);
    end
    
    if ~istable(saccades)
        msgID = 'OCT:BadArguments';
        msg   = 'First argument should be table with generated ' + ...
                'saccades parameters, see generate_saccades';
        ex    = MException(msgID, msg);
        throw(ex);
    end
    
    i = 1;
    saccadesNumber = size(saccades, 1);
    origin = struct('x', cell(1, saccadeLength * saccadesNumber), ... 
                    'y', cell(1, saccadeLength * saccadesNumber));
    origin(1).x = 1;
    origin(1).y = 1;

    for j = 1:saccadesNumber
        saccade = saccades(j,:);
        timeFromStart = saccadeLength * (j - 1);

        while i < saccadeLength * j
            origin(i + 1).x = origin(i).x - saccade.vx / saccade.lambda ...
                * exp(-saccade.lambda * (i - timeFromStart));
            origin(i + 1).y = origin(i).y - saccade.vy / saccade.lambda ...
                * exp(-saccade.lambda * (i - timeFromStart));
            i = i + 1;
        end;
    end;

end

