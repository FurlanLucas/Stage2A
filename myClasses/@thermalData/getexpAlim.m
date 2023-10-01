function dataOut = getexpAlim(obj, id)
    %% getexpAlim
    %
    % Implementation of getexp method (the same as in the System
    % Identification Toolbox) for the thermalData class, but to be used in
    % the input system identification analysis.
    %
    % Calls
    %
    %   data = thermalData.getexpAlim(id): take the id data in the mySet 
    %   thermalData variable and returns it in the format of an iddata.
    %
    %   data = thermalData.getexpAlim([id1, id2, ..., idn]): take the 
    %   data sets enumerated id1 to idn and returns it in the format of 
    %   an iddata. 
    %
    % Inputs
    %
    %   id: integer number to identify the dataset.
    %
    % Outputs
    %
    %   data: iddata object, with the entry beeing the tension applied
    %   in the front face, output beeing the measured heat flux also in the
    %   front face.
    %
    % See also: getexpAlim, thermalData.

    %% Main

    n_data = length(id);
    for i = 1:n_data

        % Create a current iddata (to each id given in the arguments)
        curr_data = iddata(obj.phi{id(i)}, obj.v{id(i)}.^2, ...
            obj.t{id(i)}(2)-obj.t{id(i)}(1));
    
        % Other additional information
        curr_data.Name = obj.Name;
        curr_data.InputName = {'Tension en entrée'};
        curr_data.InputUnit = {'V²'};
        curr_data.OutputName = {'Flux de chaleur'};
        curr_data.OutputUnit = {'W/m²'};
        curr_data.TimeUnit = 'milliseconds';
        curr_data.ExperimentName = num2str(id(i), '%04.f');
        curr_data.Tstart = 0;   

        if i == 1
            dataOut = curr_data;
        else
            dataOut = merge(dataOut, curr_data);
        end
    end

end