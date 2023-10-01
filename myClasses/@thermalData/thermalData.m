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
    %   isPRBS: integer vector with the analysis number that corresponds to
    %   PRBS as input;
    %
    %   isSteady: integer vector with the analysis number that corresponds to
    %   a steady-state analysis
    %
    %   isStep: integer vector with the analysis number that corresponds to
    %   all step responses;
    %
    %   isReentry: integer vector with the analysis number that corresponds to
    %   all reentry responses;
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
    %   phiV: 1xNe cell with the measured heat flux samples in volts, giving
    %   by the resistence current and tension, Ne being the number of 
    %   experiments;
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
        Notes = {};               % [-] User notes.
        isPRBS = [];              % [bool] PRBS data control
        isStep = [];              % [bool] Step data control
        isReentry = [];           % [bool] Reentry data control
        isSteady = [];            % [bool] Steady-state data control
    end 

    % Read only
    properties  (SetAccess = private)        
        Name = 'Empty';           % [-] Analysis name
        Ne = 0;                   % [-] Number of experiments
        t = {};                   % [ms] Time samples
        v = {};                   % [V] Input tension
        y_front = {};             % [°C] Temperature in the front face
        y_back = {};              % [°C] Température in the rear fece
        sysData = sysDataType;    % [-] System data
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

        % Take the heat flux by tension
        phi = phi(obj);

        % Get method
        get(obj);

        % Add a new experiment
        objOut = add(obj, t, v, y_back, y_front);

    end
end