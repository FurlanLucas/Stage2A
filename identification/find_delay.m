function nk = find_delay(dataIn)
    %% find_delay
    %
    % Find the system delay.

    %% Inputs
    
    % Fixed inputs
    figDir = 'outFig';                     % Output figures directory
    colors = ['r','g','b','y'];            % Figure colors
    linSty = ["-"; "--"; "-."; ":"];       % Figure line styles

    %% Init variables
    nk = zeros(dataIn.Ne, 1);

    %% Main analysis
    for i = 1:dataIn.Ne

        % Get the ith data
        data = getexp(dataIn, i);
        data.y = data.y(:,1); % Take one output only

        % Delay est method
        nk(i) = delayest(data);
        fprintf("\tFor set number %s : nk = %d;\n", ...
            data.ExperimentName{1}, nk(i));

        % Graphics
        h = impulseest(data);
        figure, showConfidence(impulseplot(h))
    end
    disp(' ');

    %% Fin de l'analyse
    msg = 'Press any key to continue...';
    input(msg);
    fprintf(repmat('\b', 1, length(msg)+3));
    close all;
    nk = 0;

end


