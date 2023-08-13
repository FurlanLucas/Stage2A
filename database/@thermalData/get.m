function get(obj)
    %% get
    %
    % Get implementation for thermalData class.

    %% Main
    
    if strcmp(obj.Name, 'Empty')
        fprintf("\nEmpty <strong>thermoData</strong> variable.\n\n");
    else
        fprintf("\nClass <strong>thermalData</strong> variavble " + ...
            "with %d different sets of data for <strong>%s</strong>" + ...
            " system.\n\n", obj.Ne, obj.Name);
        for i = 1:obj.Ne
            fprintf("\tJeux %2d: %d échantillons ;\n", i, ...
                length(obj.phi{i}));
        end
    end