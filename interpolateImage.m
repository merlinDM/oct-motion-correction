function resized = interpolateImage(image, targetRef)
    resized = imresize3(image, targetRef.ImageSize);
end

function [padded] = paddImage(I, IRef, bg, bgRef)
    [xOrigin, yOrigin, zOrigin] = intrinsicToWorld(IRef, 1, 1, 1);

    [rx, ry ,rz] = worldToSubscript(bgRef, xOrigin, yOrigin, zOrigin);
    [m, n, p] = size(I);
    cx = floor(m / 2);
    cy = floor(n / 2);
    cz = floor(p / 2);

    padded = bg; %zeros(bgRef.ImageSize);
    padded(rx-cx:rx-cx+m-1, ...
        ry-cy:ry-cy+n-1, ...
        rz-cz:rz-cz+p-1) = I;
end

function [bg, bgRef] = commonBackground(left, right)
    m = max(size(left, 1), size(right, 1));
    n = max(size(left, 2), size(right, 2));
    p = max(size(left, 3), size(right, 3));
    
    factor = 3;
    xLimits = [- m * factor m * factor];
    yLimits = [- n * factor n * factor];
    zLimits = [- p * factor p * factor];
    
    bgRef = imref3d(size(left) * factor, xLimits, yLimits, zLimits);
    bg = zeros(bgRef.ImageSize);
end