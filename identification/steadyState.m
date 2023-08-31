function h = steadyState(dataIn, varargin)
    %% steadyState
    %
    % Function to estimate the value of the heat transfer coefficient based
    % in 1D analysis. 
    %
    % Calls
    %
    %   h = steadyState(dataIn): take the steady-state data present in
    %   dataIn and stimate the value of the heat trasnfer coefficient. It
    %   uses the last 100 samplings.
    %
    %   h = steadyState(__, options): take the optional arguments.
    %
    % Inputs
    %
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated.
    %
    % Outputs
    %
    %   h: heat transfer coefficient in W/(m²K).
    %
    % Aditional options
    %
    %   M: number of samplings for taking the avarage.
    %
    % See also thermalData.

    %% Inputs
    figDir = 'outFig';            % Directory for output figures
    analysisName = dataIn.Name;   % Analysis name
    M = 100;                      % Smaplings number for steady state

    %% Directories verification and variables config

    if not(isfolder(figDir + "\" + analysisName))
        mkdir(figDir + "\" + analysisName);
    end

    % Optional inputs
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("M")
                    M = getexp(dataIn, varargin{arg, 2});
                    break;
            end
        end
    end

    %% Input dynamics

    % Take data
    t = dataIn.t{dataIn.Ne};
    phi = dataIn.phi{dataIn.Ne};
    v = dataIn.v{dataIn.Ne};

    % English
    fig = figure;
    subplot(2, 1, 1);
    plot(t/60e3, phi, 'r', LineWidth=1.5);
    grid minor; 
    ylabel({"Heat flux", "$(W/m^2)$"}, ...
        Interpreter="latex", FontSize=17);
    subplot(2, 1, 2);
    plot(t/60e3, v, 'b', LineWidth=1.5);
    ylabel("Input tension (V)", Interpreter="latex", FontSize=17);
    xlabel("Time (min)",Interpreter="latex",FontSize=17);
    grid minor; fig.Position = [385 108 611 462];
    saveas(fig, figDir + "\" + analysisName + "\" + ...
        "Change_to_flux_en.eps", 'epsc');    

    % French
    ylabel({"Tension", "d'entr\'{e}e (V)"}, Interpreter="latex", ...
        FontSize=17);
    xlabel("Temps (min)",Interpreter="latex",FontSize=17);
    subplot(2, 1, 1);
    ylabel({"Flux de chaleur", "en d'entr\'{e}e $(W/m^2)$"}, ...
        Interpreter="latex", FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\" + ...
        "Change_to_flux_fr.eps", 'epsc');    

    %% Steady state figure

    % Take data
    t = dataIn.t{dataIn.Ne+1};
    phi = dataIn.phi{dataIn.Ne+1};
    y = dataIn.y_back{dataIn.Ne+1};

    % English
    fig = figure();
    plot(t/3600e3, y, 'b', LineWidth=0.5); grid minor;
    ylabel("Temperature ($^\circ$C)", Interpreter="latex", ...
        FontSize=17);
    xlabel("Time (h)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\" + ...
        "steadyState_en.eps", 'epsc');    

    % French
    ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter="latex", ...
        FontSize=17);
    xlabel("Temps (h)",Interpreter="latex",FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\" + ...
        "steadyState_fr.eps", 'epsc');    


    %% Heat transfer coefficient

    PHI = mean(phi(end-M:end));
    TEMP = mean(y(end-M:end));
    h = dataIn.sysData.takeResArea*PHI/(dataIn.sysData.takeArea*TEMP);    

end

