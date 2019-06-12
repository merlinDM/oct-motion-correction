classdef RegistrationProcedure < handle
    
    
    properties
        transformationMode = 'field';
        optimizationProcedure = @thirdparty.lbfgs.fminlbfgs;
    end
    
    properties(SetAccess = private)
        registrationObjective;
        experimentMeta;
        optimizationProcedureOptions;
        startingPoint;
        scanningProcedure = ScannigProcedure();
    end
    
    methods
        
        function [registered, raw, scores] = registerExperiment(obj, experimentIndex)
            
            [data, meta] = obj.scanningProcedure.loadExperimentData(experimentIndex);
            
            obj.experimentMeta = meta;
            
            [raw, listOfMoving] = obj.filterExperimentData(data, 'raw');
            raw = raw.value;
            
            obj.setOptimizationProcedureOptions();
            
            obj.registrationObjective = RegistrationObjective();
            
            registered = obj.registerImageArray(listOfMoving);
            
            listOfMoving(end + 1).value = registered;
            scores = [ ...
                arrayfun(@(x) ssim(x.value, raw), listOfMoving);
                arrayfun(@(x) immse(x.value, raw), listOfMoving);
            ];
        end
        
    end
    
    methods(Access = private)
        function [left, right] = filterExperimentData(~, data, typeName)
            selectedTpe = {typeName};
            selectedIndex = cellfun(@(x) any(strcmp(x, selectedTpe)), {data.tpe});
            left = data(selectedIndex);

            selectedIndex = cellfun(@(x) any(~strcmp(x, selectedTpe)), {data.tpe});
            right = data(selectedIndex);
        end
    
        function [result] = registerImageArray(obj, arr)
            len = numel(arr);
            if len == 1
                result = arr(1).value;
                return;
            end

            nextLen = ceil(len / 2);
            nextArr(nextLen).value = [];

            for i = 1:nextLen
                if 2 * i > len
                    nextArr(i).value = arr(2 * i - 1).value;
                    continue;
                end

                fixed = arr(2 * i - 1).value;
                moving = arr(2 * i).value;
                
                registered = obj.registerImagePair(fixed, moving);
                nextArr(i).value = registered;
            end

            result = obj.registerImageArray(nextArr);
        end
        
        function [registered] = registerImagePair(obj, fixed, moving)
            r = obj.registrationObjective;
            r.fixedImage = fixed;
            r.movingImage = moving;
            r.setTransformationMode(obj.transformationMode);
            
            x = obj.optimizationProcedure( ...
                @(x) r.objective(x), ...
                obj.startingPoint, ...
                obj.optimizationProcedureOptions);
            
            registered = r.interpolate(r.transform(x));
        end
        
        function setOptimizationProcedureOptions(obj)
            meta = obj.experimentMeta;
            
            if strcmp(obj.transformationMode, 'field')
                [m, n, ~] = meta.mnp;
                obj.startingPoint = eye([m, n]);
                
                obj.optimizationProcedureOptions = struct(...
                    'Display','iter', ...
                    'HessUpdate','lbfgs', ...
                    'GoalsExactAchieve',1, ...
                    'GradConstr',false,  ...
                    'TolX', 1e-2, ...
                    'TolFun', 1e-3, ...
                    'GradObj', 'off', ...
                    'MaxIter', 400, ...
                    'MaxFunEvals', 100 * numel(obj.startingPoint) - 1,  ...
                    'DiffMaxChange', 1, ...
                    'DiffMinChange', 1e-6, ...
                    'OutputFcn', [], ...
                    'rho', 0.0100, ...
                    'sigma', 0.900, ...
                    'tau1', 3, ...
                    'tau2', 0.1, ...
                    'tau3', 0.5, ...
                    'StoreN', 20);
            elseif strcmp(obj.transformationMode, 'rigid')
                obj.startingPoint = zeros(7, 1);
                
                obj.optimizationProcedureOptions = struct(...
                    'Display','final', ...
                    'HessUpdate','lbfgs', ...
                    'GoalsExactAchieve',1, ...
                    'GradConstr',false,  ...
                    'TolX', 1e-8, ...
                    'TolFun', 1e-8, ...
                    'GradObj', 'off', ...
                    'MaxIter', 400, ...
                    'MaxFunEvals', 100 * numel(obj.startingPoint) - 1,  ...
                    'DiffMaxChange', 1e-1, ...
                    'DiffMinChange', 1e-8, ...
                    'OutputFcn', [], ...
                    'rho', 0.0100, ...
                    'sigma', 0.900, ...
                    'tau1', 3, ...
                    'tau2', 0.1, ...
                    'tau3', 0.5, ...
                    'StoreN', 20);
            end
        end
    end
end

