# OCT motion correction

This repo contains code for my masters thesis. Project is aimed to provide a solution of reducing motion artifacts in images acquired via Optical Coherence Tomography technique.

### Structure

|File|description|
|---|---|
**saccadesModeling.mlx** | Contains info about how eye movements were modeled.
**phantomModeling.mlx** | Shows how to apply saccadic motion to test data.
**metricsModeling.mxl** | Investigates image quality metrics (terrible) behaviour.
**generateSaccades.m** | Generates random parameters for the eye movement model.
**originMovement.m** | Produces vector of origin positions in time for given parameters.
**displacementField2d.m** | Transform origin movement into Displacement field  **m** x **n** x **2** matrix.
**displacementField3d.m** | Transform origin movement into Displacement field  **m** x **n** x **p** x **3** matrix.
**scripts.m** | Examples and usefull scripts.
**loadExperiment.m** | Loads data from  resources according to the specified experiment index.
**registerExperiment.m** | Applies imregister to all distorted images in experiment. Returns raw data, registered image and ssim scores array; the last element of the array is registered image score.
**visualize3d.m** | Constructs animated view of 3D matrices.
**computeSSIM.m** | Implements image registration metric for optimization.

### Usage

First, checkout project.
```bash
$ git clone https://github.com/merlinDM/oct-motion-correction.git
```

Add project to Matlab search path:
```matlab
>> cd '/path/to/project/';
>> addpath(pwd);
```

Run the example:
```matlab
>> run 'phantomModeling.mlx';
```

In 2019a it's impossible to make animation in Live Scripts. To see original and distorted image use lines (Ctrl+C in command window to stop):
```matlab
>> visualize3d(acquiredImageXFast, acquiredImageYFast);
```

Also see **scripts.m**.

### Requirements

Matlab 2019a with Image Processing Toolbox installed.

Matthias Schabel, 3D Shepp-Logan phantom project, **/+thirdparty/+phantom3d/**
https://www.mathworks.com/matlabcentral/fileexchange/9416-3d-shepp-logan-phantom

Dirk-Jan Kroon, FMINLBFGS: Fast Limited Memory Optimizer, **/+thirdparty/+lbfgs/**
https://www.mathworks.com/matlabcentral/fileexchange/23245-fminlbfgs-fast-limited-memory-optimizer

Some matrix functions by Dirk-Jan Kroon from Finite Iterative Closest Point, **/+thirdparty/+dkroon/**
https://www.mathworks.com/matlabcentral/fileexchange/24301-finite-iterative-closest-point