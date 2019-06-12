classdef RegistrationObjective < handle
    properties
        movingImage;
        fixedImage;
    end
    
    properties(SetAccess = private)
        transform;
    end
    
    methods(Access = public)
        function [score] = objective(obj, x)
            W = obj.transform(x);
            IW = obj.interpolate(W);
            score = obj.metric(IW, obj.fixedImage);
        end
        
        function [dissimularity] = metric(~, moving, fixed)
            dissimularity = (1 - ssim(moving, fixed)) / 2;        
        end
        
        function [resized] = interpolate(obj, image)
            targetRef = imref3d(size(obj.fixedImage));
            resized = imresize3(image, targetRef.ImageSize);
        end
        
        function setTransformationMode(obj, mode)
            if strcmp(mode, 'rigid')
                obj.transform = ...
                    obj.transformRigid;
            elseif strcmp(mode, 'field')
                obj.transform = ...
                    obj.transformationField;
            end
        end
    end
        
    methods(Access = private)
        function f = transformRigid(obj)
            fixedRef = imref3d(size(obj.fixedImage));
            scale = [1 1 1 0.01 0.01 0.01 0.01 0.01 0.01];

            function warped = transformation(parVector)
                tform = RegistrationObjective.vectorToAffine3d(parVector, scale);
                warped = imwarp(obj.movingImage, fixedRef, tform);
            end

            f = @transformation;
        end

        function f = transformationField(obj)
            % parVector -- MxN dispacement field matrix
            function warped = transformation(parVector)
                D(:,:,1) = parVector;
                D(:,:,2) = parVector;
                warped = imwarp(obj.movingImage, D);
            end
            
            f = @transformation;
        end
    end
    
    methods(Static)
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
    end
end

