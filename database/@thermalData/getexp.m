function dataOut = getexp(obj, id)
    %% getexp
    %
    % Implantation d'une fonction getexp pour la classe thermalData. Le
    % fonctionement de cette méthode est similaire à getexp de la toolbox
    % d'identification.
    %
    %   data = mySet.getexp(id) prend le jeux des données numéro id de
    %   l'emsemble mySet.
    %
    %   data = mySet.getexp([id1, id2, ..., idn) prend le jeux des données 
    %   énumérée id1, id2, ..., idn dans l'emsemble mySet.
   
    %% Main

    n_data = length(id);
    for i = 1:n_data

        % Crée le donnée du type 'iddata'
        curr_data = iddata([obj.y_back{id(i)}, obj.y_front{id(i)}], ...
            obj.phi{id(i)}, obj.t{id(i)}(2)-obj.t{id(i)}(1));
    
        % Des autres infos 
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