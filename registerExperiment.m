function [registered, raw, scores] = registerExperiment(experimentIndex)

    [data, meta] = loadExperimentData(experimentIndex);

    selectedTpe = {'raw'};
    selectedIndex = cellfun(@(x) any(strcmp(x, selectedTpe)), {data.tpe});
    raw = data(selectedIndex).value;

    selectedIndex = cellfun(@(x) any(~strcmp(x, selectedTpe)), {data.tpe});
    listOfMoving = data(selectedIndex);
    fixed = listOfMoving(1).value;
    scores = zeros(numel(listOfMoving) + 1, 1);

    optimizer = registration.optimizer.RegularStepGradientDescent();
    metric = registration.metric.MeanSquares();

    optimizer.GradientMagnitudeTolerance = 0.000100;
    optimizer.MinimumStepLength = 0.000010;
    optimizer.MaximumStepLength = 0.062500;
    optimizer.MaximumIterations = 100;
    optimizer.RelaxationFactor = 0.500000;

    displayOptimization = 0;
    pyramidLevels = floor(log(min(size(raw))) / log(2)) - 1;

    for i=2:numel(listOfMoving)
        moving = listOfMoving(i).value;
        scores(i - 1) = ssim(moving, raw);

        [registered, SRI] = imregister( ...
            moving, fixed, 'Rigid', ...
            optimizer, metric, ...
            'DisplayOptimization', displayOptimization, ...
            'PyramidLevels', pyramidLevels ...
        );
        fixed = registered;
    end

    scores(numel(listOfMoving)) = ssim(moving, raw);
    scores(numel(listOfMoving) + 1) = ssim(registered, raw);

end

