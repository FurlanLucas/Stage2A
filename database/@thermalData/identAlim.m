function dataOut = identAlim(obj)
    %% getIdent
    %
    % Description
    %

    %% Main

    % Crée le donnée du type 'iddata'
    dataOut = iddata(obj.v{obj.identNumber}.^2, ...
        obj.phi{obj.identNumber}, ...
        obj.t{obj.identNumber}(2)-obj.t{obj.identNumber}(1));

    % Des autres infos
    dataOut.Name = obj.Name;
    dataOut.InputName = {'Tension en entrée'};
    dataOut.InputUnit = {'V'};
    dataOut.OutputName = {'Flux de chaleur'};
    dataOut.OutputUnit = {'W/m²'};
    dataOut.TimeUnit = 'milliseconds';
    dataOut.ExperimentName = "Exp."  + num2str(obj.identNumber);
    dataOut.Tstart = 0;       

end