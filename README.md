# OCT motion correction

This repo contains code for my masters thesis. Project is aimed to provide a solution of reducing motion artifacts in images acquired via Optical Coherence Tomography technique.

### Structure

|File|Description|
|---|---|
**saccadesModeling.mlx** | Contains info about how eye movements were modeled.
**phantomModeling.mlx** | Shows how to apply saccadic motion to test data.
**metricsModeling.mxl** | Investigates image quality metrics (terrible) behaviour.
**projectTest.m** | Contains use cases for project.
**RegistrationObjective.m** | Encapsulates objective function for image registration. 
**RegistrationProcedure.m** | Loads experiment data from resources and performs registration. 
**SaccadeGenerator.m** | Generates saccadic movement.
**ScannigProcedure.m** | Modeles scanning procedure and applies saccadic movement to given original 3D image.


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

Registration procedure could be tested using
```matlab
>> runtests('projectTest')
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

Deshan Yang, Gaussian Pyramid - Expand and Reduce routines 1D, 2D and 3D, **/+thirdparty/+pyramid/**
https://www.mathworks.com/matlabcentral/fileexchange/12037-gaussian-pyramid-expand-and-reduce-routines-1d-2d-and-3d

T. Mahmudi, R. Kafieh, H. Rabbani, data from their paper OCT data & Color Fundus Images of Left & Right Eyes of 50 healthy persons
https://sites.google.com/site/hosseinrabbanikhorasgani/datasets-1/oct-fundus-right-left