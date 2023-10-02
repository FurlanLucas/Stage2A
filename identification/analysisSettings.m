function settings = analysisSettings(name, varargin)
    %% analysisSettings
    %
    % Set the analysis parameters, for instance directory names and input
    % file names. Also, includes the database and class user defined
    % directories in the current matlab path, if it was not already
    % defined. Verifies the output directories existence.
    %
    % Calls
    %
    %   analysisSettings(name): set the analysis parameters for the dataset
    %   'name' in database;
    %
    %   analysisSettings(__, options): take the optional arguments.
    %
    % Inputs
    %
    %   name: string with the dataset name. Must mach lower/upper case.
    %
    % Aditional options
    %
    %   figDir: Output figure directory's name;
    %
    %   texDir: Output tex files directory's name;
    %
    %   colors: Set available colors in the plots.
    %
    % See also Contents.

    %% Default parameters
    settings = struct();
        settings.figDir = 'outFig';  % Directory output for fig.
        settings.colors = ['r','b','g','m','c','y'];   % Graph colors
        settings.direct = false;     % Directory output for tex.
        settings.name = name;        % Analysis name

    %% Inputs

    % Verify the optional arguments
    for i=1:2:length(varargin)        
        switch varargin{i}            
            case 'figDir' % Figure directory  
                settings.figDir = varargin{i+1};          
            case 'colors' % Colors
                settings.colors = varargin{i+1};  
            case 'direct' % Close all figures
                settings.direct = varargin{i+1};
            otherwise
                error("Option '" + varargin{i} + "' is not available.");
        end
    end

    %% Verifies the directories
    if ~isfolder(settings.figDir + "\" + name)
        mkdir(settings.figDir + "\" + name);
    end

    %% Add paths
    addpath('..\database', '..\myClasses');

end