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
experimentIndex = 6;
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

%% Tranformation objective Rigid Mode

fixed = phantomImage;
moving = imrotate3(phantomImage, 90, [1 0 0]);
moving = imresize3(moving, size(fixed));

r.fixedImage = fixed;
r.movingImage = moving;
r.setTransformationMode('rigid')

x = zeros(7, 1);

res = r.objective(x);
assert(res == 0.1775)
% disp(res);

%% Tranformation objective Displacement Field Mode

fixed = phantomImage;
moving = imrotate3(phantomImage, 90, [1 0 0]);
moving = imresize3(moving, size(fixed));

r.fixedImage = fixed;
r.movingImage = moving;
r.setTransformationMode('field')

x = eye([M, N]);

res = r.objective(x); 
assert(res == 0.1788)
% disp(res);

%% Run experiment

s.rawImage = phantomImage;
s.saccadesAmplitude = 7;
s.saccadesPerImage = 4;
s.saveExperimentData(experimentIndex, experimentSize, experimentData);

%% Run registration

p.transformationMode = 'rigid';
[registered, raw, scores] = p.registerExperiment(experimentIndex);

disp(scores);