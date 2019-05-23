# OCT motion correction

This repo contains code for my masters thesis. Project is aimed to provide a solution of reducing motion artifacts in images acquired via Optical Coherence Tomography technique.

### Structure

* **saccades.mlx** Contains info about how eye movements were modeled;
* **phantom.mlx** Shows how to apply saccadic motion to test data;
* **generate_saccades.m** Generates random parameters for the eye movement model;
* **origin_movement.m** Produces vector of origin positions in time for given parameters.
* **saccades_spiral.m** Generates saccadic movement using random points on logarythmic spiral. Turned out to be too uncontrolable for our purposes.

### Usage

First, checkout project. In MATLAB, type into command line:
```matlab
>> cd '/path/to/project/'
>> run 'phantom.mlx'
```

In 2016a it's impossible to make animation in Live Scripts. To see original image use (Ctrl+C to stop):
```matlab
>> fps = 10;
>> pause on;
>> for y = 1:1000
 pause(1/fps);
 slice(phantomImage, ...
     (NMAX), (mod(y, NMAX) + 1), (NMIN))
end;
```

To show distorted image:
```matlab
>> for y = 1:1000
 pause(1/fps);
 slice(acquiredImage, ...
     (NMAX), (mod(y, NMAX) + 1), (NMIN))
end;
```

### 3rd party projects

Requires 3D Shepp-Logan phantom project.
https://www.mathworks.com/matlabcentral/fileexchange/9416-3d-shepp-logan-phantom