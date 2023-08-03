classdef thermalData
    %% sysDataType
    % Cette classe permet d'avoir l'ensamble de tous les information liées
    % à chaque réalisation experimental.
    %
    %   -> Type décrit le type de mesure realisé, ce qui peut être

    %% Proprietées --------------------------------------------------------
    properties
        Name = 'Empty';           % [-] Nom de l'analyse ;
        t = {};                   % [ms] Temps ;
        v = {};                   % [V] Tension en entrée ;
        phi = {};                 % [W/m²] Flux de chaleur en entrée ;
        y_front = {};             % [°C] Température dans la face avant ;
        y_back = {};              % [°C] Température dans la face arrière ;
        sysData = sysDataType;    % [-] Données du système ;
        identNumber = 1;          % [-] Données de identification ;
        validNumbers = 2;         % [-] Données de validation ;
        Notes = {};               % [-] Notes de l'user ;
    end 

    %% Méthodes -----------------------------------------------------------
    methods
        % Contructeur de la classe
        function obj = thermalData(sysData)
            if nargin == 1
                obj.Name = sysData.name;
                obj.sysData = sysData;
            end
        end

        % Prends le données de identification
        dataOut = ident(obj, varargin);

        % Prends le données de validation
        dataOut = valid(obj, varargin);

        % Prends le données de identification (entrée)
        dataOut = identT(obj, varargin);

        % Prends le données de valid (entrée)
        dataOut = validT(obj, varargin);

        % Get methods
        get(obj);

        % Ajoute un nouvelle jeux de données
        function obj = add(obj, y_front, y_back, v, phi, t)
            % Ajoute les données
            pos = length(obj.phi) + 1;
            obj.y_front{pos} = y_front;
            obj.y_back{pos} = y_back;
            obj.v{pos} = v;
            obj.phi{pos} = phi;
            obj.t{pos} = t;
        end

    end
end