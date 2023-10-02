function h = steadyState(dataIn, analysis, varargin)
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
    %   system that will be simulated;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories.
    %
    % Outputs
    %
    %   h: vector N x 1 of heat transfer coefficients in W/(m²K), with N
    %   the number of experiments identified as isSteady in thermalData.
    %
    % Aditional options
    %
    %   M: number of samplings for taking the avarage;
    %
    % See also thermalData.

    %% Inputs
    M = 100;  % Smaplings number for steady state

    % Verify the optional arguments
    for i=1:2:length(varargin)        
        switch varargin{i}            
            case 'M' % Number of samples to take the mean  
                M = varargin{i+1};   
            otherwise
                error("Option '" + varargin{i} + "' is not available.");
        end
    end

    n_data = length(dataIn.isSteady);
    h = zeros(n_data, 1);

    %% Main
    for i = 1:n_data

        % Input data
        y = dataIn.y_back{dataIn.isSteady(i)};
        t = dataIn.t{dataIn.isSteady(i)};
        phi = dataIn.phi{dataIn.isSteady(i)};
    
        % Steady state figure in english
        fig = figure();
        plot(t/3600e3, y, 'b', LineWidth=0.5); grid minor;
        ylabel("Temperature ($^\circ$C)", Interpreter="latex", ...
            FontSize=17);
        xlabel("Time (h)",Interpreter="latex",FontSize=17);
        saveas(fig, analysis.figDir + "\" + analysis.name + "\" + ...
            "steadyState_en.eps", 'epsc');    
    
        % Steady state figure in french
        ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter="latex", ...
            FontSize=17);
        xlabel("Temps (h)",Interpreter="latex",FontSize=17);
        saveas(fig, analysis.figDir + "\" + analysis.name + "\" + ...
            "steadyState_fr.eps", 'epsc');    
    
    
        %% Heat transfer coefficient
    
        PHI = mean(phi(end-M:end));
        TEMP = mean(y(end-M:end));
        h(i) = dataIn.sysData.takeResArea*PHI/(dataIn.sysData.takeArea*TEMP);    
    
        fprintf("\tFor %d dataset: h = %.1f WK/m²\n", i, h(i));
    end

end

