function dataOut = validAlim(obj)
    %% getIdent
    %
    % Description
    

    %% Main

    n_data = length(obj.validNumbers);
    for i = 1:n_data

        % Crée le donnée du type 'iddata'
        curr_data = iddata(obj.v{obj.validNumbers(i)}.^2, ...
            obj.phi{obj.validNumbers(i)}, ...
            obj.t{obj.validNumbers(i)}(2)-obj.t{obj.validNumbers(i)}(1));
    
        % Des autres infos 
        curr_data.Name = obj.Name;
        curr_data.InputName = {'Tension en entrée'};
        curr_data.InputUnit = {'V'};
        curr_data.OutputName = {'Flux de chaleur'};
        curr_data.OutputUnit = {'W/m²'};
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