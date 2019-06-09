function [metric] = simularityMetric(left, right, scale)

    rightRef = imref3d(size(right));
    leftRef = imref3d(size(left));

    function [simularity] = ssimF(parVector)
        % parVector should be 1x7 double parameters vector
        tform = vectorToAffine3d(parVector, scale);
        warped = imwarp(left, leftRef, tform);
        
        resizedWarped = interpolateImage(warped, rightRef);
        simularity = (1 - ssim(resizedWarped, right)) / 2;        
    end
    
    metric = @ssimF;
end