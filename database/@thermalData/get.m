function get(obj)
    %% get
    %
    % Implantation de la méthode get pour la classe thermalData

    %% Main
    
    if strcmp(obj.name, 'Empty')
        fprintf("\nVariable <strong>vide</strong> du type" + ...
            "thermalData.\n\n");
    else
        fprintf("\nVariable du type thermalData.\nDonnées " + ...
            "experimentales du système <strong>%s</strong> avec " + ...
            "%d jeux des données.\n\n", ...
            obj.name, length(obj.phi));
        for i = 1:length(obj.phi)
            fprintf("\tJeux %2d: %d échantillons ;\n", i, ...
                length(obj.phi{i}));
        end
    end