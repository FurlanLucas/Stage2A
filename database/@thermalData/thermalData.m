classdef thermalData
    %% sysDataType
    %
    % Cette classe permet d'avoir l'ensamble de tous les jeux des données
    % experimentales pour un même système.
    %
    %   Propritées :
    %
    %       Name : nom de l'analyse faite. Il sera le même que celui du
    %       sysDataType associé ;
    %
    %       t : cellule 1 x Ne avec les échantillons temporélle em ms, avec
    %       Ne le nombre de experiments realisés ;
    %
    %       v : cellule 1 x Ne avec tension mésuré en entrée de la
    %       résistance en V, avec Ne le nombre de experiments realisés ;
    %
    %       phi : cellule 1 x Ne avec tension mésuré en sortie du capeteur
    %       de flux termique, avec Ne le nombre de experiments realisés ;
    %
    %       y_front : cellule 1 x Ne avec tension mésuré en sortie du 
    %       termocouple placé dans la face avant, avec Ne le nombre de 
    %       experiments realisés ;
    %
    %       y_back : cellule 1 x Ne avec tension mésuré en sortie du 
    %       termocouple placé dans la face arrière, avec Ne le nombre de 
    %       experiments realisés ;
    %
    %       sysData : les information liées à chaque réalisation, du type 
    %       << sysDataType >>.
    %
    %       Notes : notes de l'user.
    %
    %   Méthodes :
    %
    %       getexp(id) : il prend un jeux des données identifié comme id ; 
    %
    %       getexpAlim(id) : il prend un jeux des données identifié comme 
    %       id pour l'identification d'entrée ;
    %
    %       add(obj, y_front, y_back, v, phi, t) : il ajoute un nouveau
    %       jeux des données au ensemble.
    %
    % See also getexp, getexpAlim, sysDataType.

    %% Proprietées --------------------------------------------------------
    properties
        Name = 'Empty';           % [-] Nom de l'analyse ;
        t = {};                   % [ms] Temps ;
        v = {};                   % [V] Tension en entrée ;
        phi = {};                 % [W/m²] Flux de chaleur en entrée ;
        y_front = {};             % [°C] Température dans la face avant ;
        y_back = {};              % [°C] Température dans la face arrière ;
        sysData = sysDataType;    % [-] Données du système ;
        Notes = {};               % [-] Notes de l'user ;
    end 

    %% Méthodes -----------------------------------------------------------
    methods
        % Contructeur de la classe
        function obj = thermalData(sysData)
            if nargin == 1
                obj.Name = sysData.Name;
                obj.sysData = sysData;
            end
        end

        % Prends un (ou plusiers) jeux des données
        dataOut = getexp(obj, id);

        % Prends un (ou plusiers) jeux des données (alimentation)
        dataOut = getexpAlim(obj, id);

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