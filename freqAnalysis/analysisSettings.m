function settings = analysisSettings(varargin)
    %% analysisSettings
    %
    % Set the analysis parameters, for instance directory names and input
    % file names.

    %% Default parameters
    settings = struct();
        settings.figDir = 'outFig';            % Directory output  
        settings.colors = ['r','b','g','m'];   % Graph colors

    %% Inputs

    % Verify the optional arguments
    for i=1:2:length(varargin)        
        switch varargin{i}            
            case 'figDir' % Minimum frequency  
                settings.figDir = varargin{i+1};          
            case 'colors' % Maximum frequency
                settings.colors = varargin{i+1};
            otherwise
                error("Option '" + varargin{i} + "' is not available.");
        end
    end

end