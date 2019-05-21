# OCT motion correction

This repo contains code for my masters thesis. Project is aimed to provide a solution of reducing motion artifacts in images acquired via Optical Coherence Tomography technique.

### Structure

* **saccades.mlx** Contains info about how eye movements were modeled;
* **phantom.mlx** Shows how to apply saccadic motion to test data;
* **generate_saccades.m** Generates random parameters for the eye movement model;
* **origin_movement.m** Produces vector of origin positions in time for given parameters.

### Usage

First, checkout project. In MATLAB, type in:
```matlab
>> cd '/path/to/project/'
>> run 'phantom.mlx'
```

In 2016a it's impossible to make animation in Live Scripts. To see original image use:
```matlab
>> fps = 10;
>> pause on;
>> for x = 1:1000
 pause(1/fps);
 slice(phantom, ...
     (NMAX), (mod(x, NMAX) + 1), (NMIN))
end;
```

To show disturted image:
```matlab
>> for x = 1:1000
 pause(1/fps);
 slice(acquiredImage, ...
     (NMAX), (mod(x, NMAX) + 1), (NMIN))
end;
```