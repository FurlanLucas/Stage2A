function nk = find_delay(dataIn)
    %% FIND_DELAY
    %
    % Analyse du delay dy système nk. Il va returner le delay comme une
    % structure avec.

    %% Entrées
    
    % Paramètres de la simulation
    figDir = 'outFig';                     % [-] Dossier pour les figures ;
    colors = ['r','g','b','y'];            % [-] Couleurs des graphiques ;
    linSty = ["-"; "--"; "-."; ":"]; % [-] Type de trace ;

    n_data = size(dataIn, 4);
    nk = zeros(n_data, 1);

    %% Main partie
    for i = 1:n_data

        % Avec la function delayest
        data = getexp(dataIn, i);
        nk(i) = delayest(data);
        fprintf("\tPour le jeux %s : nk = %d ;\n", ...
            data.ExperimentName{1}, nk);

        % Graphiquement
        h = impulseest(data);
        figure, showConfidence(impulseplot(h))
    end

    %% Sortie
    nk = mean(nk);

end


