function nk = find_delay(dataIn)
    %% find_delay
    %
    % Find the system delay.

    %% Inputs
    
    % Fixed inputs
    figDir = 'outFig';                     % Output figures directory
    colors = ['r','g','b','y'];            % Figure colors
    linSty = ["-"; "--"; "-."; ":"];       % Figure line styles

    %% Main analysis
    for i = 1:dataIn.Ne

        % Get the ith data
        data = getexp(dataIn, i);
        data.y = data.y(:,1); % Take one output only

        % Delay est method
        nk = delayest(data);
        fprintf("\tPour le jeux %s : nk = %d ;\n", ...
            data.ExperimentName{1}, nk);

        % Graphics
        h = impulseest(data);
        figure, showConfidence(impulseplot(h))
    end
    disp(' ');

    %% Output
    nk = 0;

end


