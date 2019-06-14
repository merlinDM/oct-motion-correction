%
%   COMMON SECTION
%

% Generate test image
import thirdparty.phantom3d.*

NMAX = 30;
NMIN = 1;
fps = 10;

phantomImage = phantom3d('shepp-logan', NMAX);
phantomImage = imresize3(phantomImage, [40 30 20]);

[M, N, P] = size(phantomImage);

% Define experiment setup
try
    rmdir './resources/experiment_99/'
catch ME
    if (strcmp(ME.identifier,'MATLAB:RMDIR:NotADirectory'))
        warning(ME.message);
    else
        rethrow(ME);
    end
end
experimentIndex = 99;
experimentSize = 3;
experimentData = 'phantomImage';

% Initialization
r = RegistrationObjective();
p = RegistrationProcedure();
g = SaccadeGenerator();
s = ScannigProcedure();

%% Test saccades generation

saccades = g.generateSaccades();
assert(istable(saccades), 'Saccades should be structured as table')
origin = g.saccadesToOriginMovement(saccades);
D = g.originMovementToDisplacementField(origin, M, N);
distortedImage = imwarp(phantomImage, D);

%% Tranformation objective Rigid Mode

fixed = phantomImage;
moving = imrotate3(phantomImage, 90, [1 0 0]);
moving = imresize3(moving, size(fixed));

r.fixedImage = fixed;
r.movingImage = moving;
r.setTransformationMode('rigid')

x = zeros(7, 1);

res = r.objective(x);
disp('Rigid transformation score')
disp(res);

%% Tranformation objective Displacement Field Mode

fixed = phantomImage;
moving = imrotate3(phantomImage, 90, [1 0 0]);
moving = imresize3(moving, size(fixed));

r.fixedImage = fixed;
r.movingImage = moving;
r.setTransformationMode('field')

dummy = zeros([M, N]);
x(:,:,1) = dummy;
x(:,:,2) = dummy;

res = r.objective(x); 
disp('Field transformation score')
disp(res);

%% Run experiment

s.rawImage = phantomImage;
s.saccadesAmplitude = 7;
s.saccadesPerImage = 4;
s.saveExperimentData(experimentIndex, experimentSize, experimentData);

%% Run rigid registration

p.transformationMode = 'rigid';
[registered, raw, scores] = p.registerExperiment(experimentIndex);

disp('Rigid registration')
disp(scores);

%% Run field registration

p.transformationMode = 'field';
[registered, raw, scores] = p.registerExperiment(experimentIndex);

disp('Field registration')
disp(scores);