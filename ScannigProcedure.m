classdef ScannigProcedure < handle    
    properties
        rawImage;
        saccadesPerImage = 2;
        saccadesAmplitude = 1;
    end
    
    properties(Access = private)
        dimentions;
        xfastConst = 'xfast';
        yfastConst = 'yfast';
        saccadeGenerator = SaccadeGenerator();
    end
    
    methods
        function saveExperimentData(obj, experimentIndex, experimentSize, prefix)
            experiment.index = experimentIndex;
            experiment.size = experimentSize;
            experiment.dir = sprintf('%s\\resources\\experiment_%02d', pwd, experiment.index);
            experiment.prefix = prefix;
            experiment.namesFormat = strcat(experiment.prefix, '_%02d_%s.mat');
            experiment.dims = '3d';
            experiment.mnp = size(obj.rawImage);
            
            [m, n, p] = size(obj.rawImage);
            experiment.saccadeLength = ceil(m * n / obj.saccadesPerImage);
            
            originalImage = obj.rawImage;
            
            mkdir(experiment.dir);
            save(strcat(experiment.dir, '\', sprintf(experiment.namesFormat, 0, 'raw')), 'originalImage');

            for i = 1:experiment.size
                direction = 'xfast';
                if rem(i, 2) == 1
                    direction = 'yfast';
                end
                
                distortedImage = obj.acquireImage(direction);
                
                filepath = strcat(experiment.dir, '\', sprintf(experiment.namesFormat, i, direction));
                save(filepath, 'distortedImage');
            end

            filepath = strcat(experiment.dir, '\', 'meta.mat');
            save(filepath, 'experiment');
        end
        
        function [image] = acquireImage(obj, direction)
            
            if nargin < 2
                direction = obj.xfastConst;
            end
            
            obj.dimentions = ndims(obj.rawImage);
            [m, n, p] = size(obj.rawImage);
            
            saccadeLength = floor(m * n / obj.saccadesPerImage);
            
            obj.saccadeGenerator.timePeriod = m * n;
            obj.saccadeGenerator.saccadeLength = saccadeLength;
            vx = obj.saccadeGenerator.saccadeConstants(1);
            vy = obj.saccadeGenerator.saccadeConstants(2);
            lambda = obj.saccadeGenerator.saccadeConstants(3);
            obj.saccadeGenerator.saccadeConstants = ... 
                [vx * obj.saccadesAmplitude, ...
                 vy * obj.saccadesAmplitude, ...
                 lambda];
            
            saccades = obj.saccadeGenerator.generateSaccades();
            origin = obj.saccadeGenerator.saccadesToOriginMovement(saccades);            
            
            D = obj.saccadeGenerator. ...
                originMovementToDisplacementField(origin, m, n, p, direction);
            
            image = imwarp(obj.rawImage, D);
        end
    end
    
    methods(Static)
        function [data, meta] = loadExperimentData(experimentIndex)

            folder = strcat('\resources\experiment_', ...
                sprintf('%02d', experimentIndex), ...
                '\');
            E = load(strcat(pwd, folder, 'meta.mat'));
            meta = E.experiment;
            r = dir(strcat(meta.dir, '\', meta.prefix, '*'));

            data = struct('value', cell(1, numel(r)), ... 
                          'tpe',   cell(1, numel(r)));
            
            for i = 1:numel(r)
                filename = strcat(r(i).folder, '\', r(i).name);
                mat = load(filename);
                if isfield(mat,'originalImage')
                    data(i).value = mat.originalImage;
                    data(i).tpe = 'raw';
                elseif isfield(mat,'distortedImage')
                    data(i).value = mat.distortedImage;
                    data(i).tpe = 'distorted';
                end
            end
        end
    end
end

