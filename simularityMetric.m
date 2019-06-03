function [metric] = simularityMetric(left, right, scale)

    rightRef = imref3d(size(right));
    leftRef = imref3d(size(left));
   
    function [simularity] = ssimF(parVector)
        import thirdparty.dkroon.getransformation_matrix;
        
        tform = getransformation_matrix(parVector, scale);
        tform = double(tform)';
        tform = affine3d(tform);
        [warped, warpedRef] = imwarp(left, leftRef, tform);
        
        [bg, bgRef] = commonBackground(warped, right);
        
        paddedRight = paddImage(right, rightRef, bg, bgRef);
        paddedWarped = paddImage(warped, warpedRef, bg, bgRef);

        simularity = ssim(paddedWarped, paddedRight);
    end
    
    metric = @ssimF;
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
    xLimits = [-m * factor m * factor];
    yLimits = [-n * factor n * factor];
    zLimits = [-p * factor p * factor];
    
    bgRef = imref3d(size(left) * factor, xLimits, yLimits, zLimits);
    bg = zeros(bgRef.ImageSize);
end