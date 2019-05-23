function [ D ] = displacement_field_2d( origin, m, n, fastAxis )
    if nargin < 4
        fastAxis = 'xfast';
    end
    
    if nargin < 3
        n = m;
    end

    cc = [origin.x; origin.y]';
    D = reshape(cc, m, n, 2);

    if strcmp(fastAxis, 'yfast')
        D = permute(D, [2 1 3]);
    end
end

