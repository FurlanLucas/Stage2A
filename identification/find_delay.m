function find_delay(dataIn, analysis)
    %% find_delay
    %
    % Find the system delay by time response, frequency spectrum,
    % correlation and impulse response.
    %
    % Calls
    %
    %   find_delay(dataIn, analysis): analyses the delay for all dataset in
    %   dataIn, using the configuration giving in analysis.
    %
    % Inputs
    %
    %   dataIn: thermalData object with all datasets to be analysed;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories.
    %
    % See also Contents, thermalData, delay_matlabMethods, delay_corrFFT,
    % analysisSettings.

    %% Inputs

    if ~isfolder(analysis.figDir + "\" + analysis.name + "\delay")
        mkdir(analysis.figDir + "\" + analysis.name + "\delay");
    end

    %% Main
    
    disp("Delay indentification for temperature in the rear face");
    delay_matlabMethods(dataIn, analysis, 1);
    delay_corrFFT(dataIn, analysis, 1);

    disp("Delay indentification for temperature in the front face");
    delay_matlabMethods(dataIn, analysis, 2);
    delay_corrFFT(dataIn, analysis, 2);

end


