function convertData()
    %% convertData
    %
    % File to convert the raw data to a set of .m data to be used in the
    % analysis. The last data is the simulation for reentry.
    %
    % Calls
    %
    %   convertData(): convert all the raw data and saves it in the output
    %   directory. Doesn't load the variables to the workspace.
    %
    % See also sysInfo, thermalData.
    
    %% Entrées et définitions
    dirInputName = 'rawData'; % File with the raw data to be converted
    dirOutputName = 'convertedData'; % Output file location (converted data)
    sysInfo; % Take system information (sysDataType)

    fprintf("<strong>Data convertion</strong>\n");
    
    %% Main
    
    allFileNames = {dir(dirInputName + "\*.txt").name};
    
    for i = 1:length(sysData)  % Cherche chaque système
        fprintf("Converting data for system %s.\n", sysData(i).Name);
    
        % Create the thermoData variable
        expData = thermalData(sysData(i));
    
        % Search in the directory
        pos = contains(allFileNames, sysData(i).Name);
        fileNames = allFileNames(pos);
        n_files = sum(pos);
    
        % For each file
        for j = 1:n_files
    
            % Lists all files
            opts = delimitedTextImportOptions("Delimiter", '\t', ...
                'VariableNames', {'t','y_back','v','y_front','phi'});
            dataRead = readtable(dirInputName + "\" + fileNames{j}, opts); 
    
            % Transform table into array
            t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
            y_back = str2double(strrep(dataRead.y_back(4:end),',','.'));
            v = str2double(strrep(dataRead.v(4:end,1), ',', '.'));
            y_front = str2double(strrep(dataRead.y_front(4:end), ',','.'));            
            
            % Transforme the outputs in variation of outputs
            y_front = sysData(i).setOutputFront(toVar(y_front));
            y_back = sysData(i).setOutputBack(toVar(y_back));
            v = toVar(v);

            
            % Other information
            expData.y_front{j} = y_front;
            expData.y_back{j} = y_back;
            expData.v{j} = v;
            expData.t{j} = t;
            
        end   
        
        % Save the thermoData variable
        steadyState = strfind({allFileNames{pos}}, 'S0');
        expData.Ne = n_files - length([steadyState{:}]) - 1;
        save(dirOutputName + "\" +sysData(i).Name, "expData");
    end

    disp(" ");

end