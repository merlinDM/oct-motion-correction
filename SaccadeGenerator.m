classdef SaccadeGenerator < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        timePeriod = 1600;
        saccadeLength = 100;
        generatorTpe = 'ellipse';
        saccadeConstants = [420 420 100];
    end
    
    properties(SetAccess = private)
        generator
    end
    
    methods
        function [saccades] = generateSaccades(obj)
            if isempty(obj.generator)
                obj.setGeneratorTpe('ellipse');
            end

            saccadesNumber = ceil(obj.timePeriod / obj.saccadeLength);

            saccades_velocities = obj.generator(saccadesNumber);
            saccades_lambda = obj.generateLambdas(saccadesNumber);

            saccades = [saccades_velocities saccades_lambda];

            constants = repmat(obj.saccadeConstants, saccadesNumber, 1);

            saccades = array2table(saccades .* constants, ...
                'VariableNames', {'vx', 'vy', 'lambda'});
        end
        
        function setGeneratorTpe(obj, tpe)
            switch tpe
                case 'ellipse'
                    obj.generator = @obj.generateEllipseVelosities;
                case 'spiral'
                    obj.generator = @obj.generateSpiralVelosities;
                case 'periodic'
                    obj.generator = @obj.generatePeriodicVelosities;
                otherwise
                    msgID = 'OCT:BadArguments';
                    msg   = 'Generator type should be one of ';
                    msg   = msg + '[ellipse, spiral, periodic]';
                    ex    = MException(msgID, msg);
                    throw(ex);
            end
            
            obj.generatorTpe = tpe;
        end
        
        function [ origin ] = saccadesToOriginMovement(obj, saccades)
            if ~istable(saccades)
                msgID = 'OCT:BadArguments';
                msg   = 'First argument should be table with generated ' + ...
                        'saccades parameters, see generateSaccades';
                ex    = MException(msgID, msg);
                throw(ex);
            end

            i = 1;
            saccadesNumber = size(saccades, 1);
            origin = struct('x', cell(1, obj.saccadeLength * saccadesNumber), ... 
                            'y', cell(1, obj.saccadeLength * saccadesNumber));
            origin(1).x = 1;
            origin(1).y = 1;

            for j = 1:saccadesNumber
                saccade = saccades(j,:);
                timeFromStart = obj.saccadeLength * (j - 1);

                while i < obj.saccadeLength * j
                    origin(i + 1).x = origin(i).x - saccade.vx / saccade.lambda ...
                        * exp(-saccade.lambda * (i - timeFromStart));
                    origin(i + 1).y = origin(i).y - saccade.vy / saccade.lambda ...
                        * exp(-saccade.lambda * (i - timeFromStart));
                    i = i + 1;
                end
            end

        end
    end
    
    methods(Access = private, Static)
        
        function [ velocities ] = generatePeriodicVelosities(obj, saccadesNumber)
            vx = p_generate_periodic_velosities(saccadesNumber, 'x');
            vy = p_generate_periodic_velosities(saccadesNumber, 'y');
            velocities = [vx vy];
        end
        
        % 0.5..1.0
        function [ velocities ] = p_generate_periodic_velosities(saccadesNumber, axis)

            if nargin < 2
                axis = 'x';
            end

            if axis == 'x'
                period = [1 -1  1 -1];
            elseif axis == 'y'
                period = [1  1 -1 -1];
            end

            periodSize = size(period, 2);
            N = ceil(saccadesNumber / periodSize) * periodSize;
            periods = repmat(period, 1, floor(N / periodSize))';

            randomVelocities = rand(N, 1) / 2;
            periodicVelocities = randomVelocities .* periods;
            velocities = periodicVelocities(1:saccadesNumber);
        end
        
        function [ velocities ] = generateSpiralVelosities(saccadesNumber)
            a = 0.5; b = 0.1; c = 1 / pi;
            fx = @(t) a * exp(b * (t - 2)) * sin((t - 2) / c);
            fy = @(t) a * exp(b * (t - 2)) * cos((t - 2) / c);

            randomVelocities = rand(saccadesNumber, 1) * 2 - 1;

            vx = arrayfun(fx, randomVelocities);
            vy = arrayfun(fy, randomVelocities);
            spiralVelocities = [vx vy];

            velocities = spiralVelocities(1:saccadesNumber,:);
        end
        
        % 0.0..0.5
        function [ velocities ] = generateEllipseVelosities(saccadesNumber)
            a = 0.5; 
            e = 0.8;
            b = sqrt(a ^ 2 * (1 - e ^ 2));
            fx = @(t) a * sin(t - 1);
            fy = @(t) b * cos(t - 1);

            period = [1 -1];

            periodSize = size(period, 2);
            N = ceil(saccadesNumber / periodSize) * periodSize;
            periods = repmat(period, 1, floor(N / periodSize))';

            randomVelocities = rand(N, 1);

            % periodic [    pi / 2 ... 3 / 2 * pi] and 
            %          [3 / 2 * pi ... 5 / 2 * pi]
            periodicVelocities = randomVelocities .* periods * pi + 3 / 2 * pi;

            vx = arrayfun(fx, periodicVelocities);
            vy = arrayfun(fy, periodicVelocities);
            ellipseVelocities = [vx vy];

            velocities = ellipseVelocities(1:saccadesNumber,:);
        end
        
        % 0.8..0.9
        function [ lambdas ] = generateLambdas(saccadesNumber)
            lambdas = 1 - (rand(saccadesNumber, 1) + 1) / 10;
        end
        
    end
    
    methods(Static)
        
    end
end

