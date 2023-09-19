function [t, v, y_b, y_f] = text2variable(name)
    %% text2variable
    %
    % Function to read the data from a text file - generated from a DAS REC
    % file - and decompose in each variable.

    %% Input
    inputDir = 'inputFiles';    % Input directory name
    firstSamplings = 1000;      % Number of samplings in the beginning

    %% Main

    opts = delimitedTextImportOptions("Delimiter", '\t', ...
        'VariableNames', {'t','y_back','v','y_front','phi'});
    dataRead = readtable(inputDir + "\" + name, opts); 

    t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
    y_b = str2double(strrep(dataRead.y_back(4:end),',','.'));
    v = str2double(strrep(dataRead.v(4:end,1), ',', '.'));
    y_f = str2double(strrep(dataRead.y_front(4:end), ',','.')); 

    % Variation of outputs
    y_b = y_b - mean(y_b(1:firstSamplings));
    y_f = y_f - mean(y_f(1:firstSamplings));

    y_b = y_b(1:4000);
    t = t(1:4000);

end