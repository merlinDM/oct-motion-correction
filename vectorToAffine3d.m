function tform = vectorToAffine3d(parVector, scale)
    import thirdparty.dkroon.getransformation_matrix;
    
    % since there is no rotation in modeled movement
    % and no scaling
    rotation = [0 0 0];
    scaling = [1 1 1];
    
    par = parVector .* scale;
    par = [par(1:3) rotation scaling par(4:9)];
    
    tform = getransformation_matrix(par);
    tform = double(tform)';
    tform = affine3d(tform);
end