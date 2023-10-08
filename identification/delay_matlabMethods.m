function delay_matlabMethods(dataIn, analysis, type)
    %% delay_matlabMethods
    %
    % Search the delay by impulseest and delayest methods. In the first
    % technique is base in the estimation of the first sampling outside the
    % confidence region and the second one is base in the optimization of a
    % ARX model with respect to the delay input.
    %
    % Calls
    %
    %   delay_matlabMethods(dataIn, analysis, type): estimate the system's 
    %   delay. If type==1, the analysis will be done with respect to the 
    %   back face model and if type==2 it will be done with respect to the 
    %   front face model.
    %
    % Inputs
    %
    %   dataIn: thermalData object with all datasets to be analysed;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %   
    %   type: switch between back temperature analysis for type=1 and 
    %   front temperature analysis for type=2.
    %
    % See also Contents, thermalData, analysisSettings.

    %% Inputs
    analysisName = analysis.name;
    outDir = analysis.figDir;

    nk = zeros(dataIn.Ne, 1);

    if type == 1
        typeName = "flux";
    elseif type == 2
        typeName = "temp";
    else
        error("Type not valid.");
    end

    %% Main

    for i = 1:dataIn.Ne

        % Get the ith data
        data = getexp(dataIn, i);
        data.y = data.y(:, type); % Take one output only

        % Delay est method
        nk(i) = delayest(data);
        fprintf("\tFor set number %s : nk = %d;\n", ...
            data.ExperimentName{1}, nk(i));

        % Graphics
        h = impulseest(data);
        fig = figure; showConfidence(impulseplot(h));
        saveas(fig, outDir + "\" + analysisName + "\delay" + ...
            "\impulseEst_" + typeName + "_" + i + "_en.fig");
    end
    disp(' ');

    %% Ending

    if ~analysis.direct
        msg = 'Press any key to continue...';
        input(msg);
        fprintf(repmat('\b', 1, length(msg)+3));
    end
    
    close all;

end