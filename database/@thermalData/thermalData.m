classdef thermalData
    %% sysDataType
    %
    % Class with all experimental data and system variables. Has the
    % implementation of getexp to take some iddata.
    %
    % Properties
    %
    %   Name: analysis name (it will be the same as used in the sysData
    %   type associeted with it;
    %
    %   Ne: number of experiments realised;
    %   
    %   t: 1xNe cell with time samples in milliseconds, Ne being the number
    %   of experiments;
    %
    %   v: 1xNe cell with the measured tension applied to the resistence
    %   samples in volts, Ne being the number of experiments;
    %
    %   phi: 1xNe cell with the measured heat flux samples in volts, Ne 
    %   being the number of experiments;
    %
    %   y_back: 1xNe cell with the measured temperature samples in volts
    %   for the rear face, Ne being the number of experiments;
    %
    %   y_back: 1xNe cell with the measured temperature samples in volts
    %   for the rear face, Ne being the number of experiments;
    %
    %   sysData: system data, specified as a sysDataType;
    %
    %   Notes: user notes for the experiments Could be different from the
    %   notes in sysData.
    %
    % Methodes
    %
    %   getexp(id) : take a experiment data set as an iddata for the system
    %   identification analysis. The data id will be taken;
    %
    %   getexpAlim(id) : take a experiment data set as an iddata for the 
    %   system identification analysis for the input heat flux. The data id 
    %   will be taken;
    %
    %   add(obj, y_front, y_back, v, phi, t) : will add a new data set to
    %   the current objetc.
    %
    % See also getexp, getexpAlim, sysDataType.

    %% Proprerties ----------------------------------------------------------------
    properties
        Name = 'Empty';           % [-] Analysis name
        Ne = 0;                   % [-] Number of experiments
        t = {};                   % [ms] Time samples
        v = {};                   % [V] Input tension
        phi = {};                 % [W/m²] Heat flux
        y_front = {};             % [°C] Temperature in the front face
        y_back = {};              % [°C] Température in the rear fece
        sysData = sysDataType;    % [-] System data
        Notes = {};               % [-] User notes.
    end 

    %% Methods --------------------------------------------------------------------
    methods

        % Class constructor
        function obj = thermalData(sysData)
            if nargin == 1
                obj.Name = sysData.Name;
                obj.sysData = sysData;
            end
        end

        % Take a data set as iddata
        dataOut = getexp(obj, id);

        % Take a data set as iddata (for input analysis)
        dataOut = getexpAlim(obj, id);

        % Get method
        get(obj);

        % Add a new dataset
        function obj = add(obj, y_front, y_back, v, phi, t)   
            obj.Ne = obj.Ne+1;
            obj.y_front{obj.Ne} = y_front;
            obj.y_back{obj.Ne} = y_back;
            obj.v{obj.Ne} = v;
            obj.phi{obj.Ne} = phi;
            obj.t{obj.Ne} = t;
        end

    end
end