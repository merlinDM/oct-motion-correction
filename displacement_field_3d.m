function [ D ] = displacement_field_3d( origin, m, n, p, fastAxis )
    
    if nargin < 5
        fastAxis = 'xfast';
    end
    
    if nargin < 4
        p = n;
    end
    
    if nargin < 3
        n = m;
    end
    
    if ~isfield(origin, 'z')
        z_movement = zeros(m * n, 1)';
    else
        z_movement = origin.z;
    end
    
    singleLayer = [origin.x; origin.y; z_movement]';
    allLayers = repmat(singleLayer, p, 1);

    D = reshape(allLayers, m, n, p, 3);
    if strcmp(fastAxis, 'yfast')
        D = permute(D, [2 1 3 4]);
    end
end

