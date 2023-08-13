function dataOut = getexp(obj, id)
    %% getexp
    %
    % Implementation of getexp method (the same as in the System
    % Identification Toolbox) for the thermalData class. 
    %
    % Calls
    %
    %   data = thermalData.getexp(id): take the id data in the mySet 
    %   thermalData variable and returns it in the format of an iddata.
    %
    %   data = thermalData.getexp([id1, id2, ..., idn]): take the data
    %   sets enumerated id1 to idn and returns it in the format of an 
    %   iddata. 
    %
    % Inputs
    %
    %   id: integer number to identify the dataset.
    %
    % Outputs
    %
    %   data: iddata object, with the entry beeing the heat flux measured
    %   in the front face, outputs beeing the temperatures measured in both
    %   faces.
    %
    % See also: getexpAlim, thermalData.
   
    %% Main

    n_data = length(id);
    for i = 1:n_data

        % Create a current iddata (to each id given in the arguments)
        curr_data = iddata([obj.y_back{id(i)}, obj.y_front{id(i)}], ...
            obj.phi{id(i)}, obj.t{id(i)}(2)-obj.t{id(i)}(1));
    
        % Other additional information
        curr_data.Name = obj.Name;
        curr_data.InputName = {'Flux de chaleur'};
        curr_data.InputUnit = {'W/m²'};
        curr_data.OutputName = {'Température arrière','Température avant'};
        curr_data.OutputUnit = {'°C','°C'};
        curr_data.TimeUnit = 'milliseconds';
        curr_data.ExperimentName =  num2str(id(i), '%04.f');
        curr_data.Tstart = 0;    
   
        if i == 1
            dataOut = curr_data;
        else
            dataOut = merge(dataOut, curr_data);
        end
    end

end