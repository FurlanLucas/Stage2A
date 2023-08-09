function dataOut = getexpAlim(obj, id)
    %% getexpAlim
    %
    % Implantation d'une fonction getexp pour la classe thermalData. Le
    % fonctionement de cette méthode est similaire à getexp de la toolbox
    % d'identification. Il prendre les données associé avec l'entrée de
    % tension/flux de chaleur du systéme.
    %
    %   data = mySet.getexp(id) prend le jeux des données numéro id de
    %   l'emsemble mySet.
    %
    %   data = mySet.getexp([id1, id2, ..., idn) prend le jeux des données 
    %   énumérée id1, id2, ..., idn dans l'emsemble mySet.
    %
    % La particularité de cette fonction est que elle va prendre la sortie
    % comme un jeux des données dans lequel l'entrée est la tension
    % apliquée dans la resistance et la sortie est le flux de chaleur.

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