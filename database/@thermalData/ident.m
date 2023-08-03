function dataOut = ident(obj)
    %% getIdent
    %
    % Description
    %

    %% Main

    % Crée le donnée du type 'iddata'
    dataOut = iddata([obj.y_back{obj.identNumber}, ...
        obj.y_front{obj.identNumber}], ...
        obj.phi{obj.identNumber}, ...
        obj.t{obj.identNumber}(2)-obj.t{obj.identNumber}(1));

    % Des autres infos
    dataOut.Name = obj.Name;
    dataOut.InputName = {'Flux de chaleur'};
    dataOut.InputUnit = {'W/m²'};
    dataOut.OutputName = {'Température arrière', 'Température avant'};
    dataOut.OutputUnit = {'°C', '°C'};
    dataOut.TimeUnit = 'milliseconds';
    dataOut.ExperimentName = "Exp."  + num2str(obj.identNumber);
    dataOut.Tstart = 0;       

end