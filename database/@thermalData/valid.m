function dataOut = valid(obj)
    %% getIdent
    %
    % Description
    

    %% Main

    n_data = length(obj.validNumbers);
    for i = 1:n_data

        % Crée le donnée du type 'iddata'
        curr_data = iddata([obj.y_back{obj.identNumber}, ...
            obj.y_front{obj.identNumber}], ...
            obj.phi{obj.identNumber}, ...
            obj.t{obj.identNumber}(2)-obj.t{obj.identNumber}(1));
    
        % Des autres infos 
        curr_data.Name = obj.Name;
        curr_data.InputName = {'Flux de chaleur'};
        curr_data.InputUnit = {'W/m²'};
        curr_data.OutputName = {'Température arrière', 'Température avant'};
        curr_data.OutputUnit = {'°C', '°C'};
        curr_data.TimeUnit = 'milliseconds';
        curr_data.ExperimentName = "Exp. " + num2str(obj.validNumbers);
        curr_data.Tstart = 0;    
   
        if i == 1
            dataOut = curr_data;
        else
            dataOut = merge(dataOut, curr_data);
        end
    end

end