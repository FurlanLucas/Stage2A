function dataOut = getexpAlim(obj, id)
    %% getIdent
    %
    % Description
    %

    %% Main

    n_data = length(id);
    for i = 1:n_data

        % Crée le donnée du type 'iddata'
        curr_data = iddata(obj.phi{id(i)}, obj.v{id(i)}.^2, ...
            obj.t{id(i)}(2)-obj.t{id(i)}(1));
    
        % Des autres infos
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