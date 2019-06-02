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
        elseif isfield(mat,'phantomImage')
            data(i).value = mat.phantomImage;
            data(i).tpe = 'raw';
        else
            data(i).value = mat.distortedImage;
            data(i).tpe = 'distorted';
        end
    end

end

