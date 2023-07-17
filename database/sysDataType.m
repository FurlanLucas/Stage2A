classdef sysDataType
    %% sysDataType
    % Cette classe permet d'avoir l'ensamble de tous les information liées
    % à chaque réalisation experimental.
    %
    %   -> Type décrit le type de mesure realisé, ce qui peut être
    %   'tension', 'flux' ou 'both'; Si le type a été configuré comme
    %   'tension', donc le flux de chaleur en entrée sera estimée par
    %   rapport à les valeurs des résistances choffantes. Si il a été
    %   configuré comme flux, il va être utilisé directement comme entrée
    %   du modèle, sans comparaison avec la tension. Si il est marqué comme
    %   'both', il va utilisé le flux mesuré, mais des comparaison des
    %   données seront possibles (les valeurs des tensions seront
    %   enregistrée dans 'UserData'.

    %% Proprietées --------------------------------------------------------
    properties
        name = 'Empty';         % [-] Nom de l'analyse ;
        geometry = 'None';      % [-] Type of the geometry ;
        size = 0;               % [m] Lateral size of the thermocouple ;
        type = 'None';          % [-] Type de mesure realisé en entrée ;
        R = 0;                  % [Ohm] Résistance choffante ;
        R_ = 0;                 % [Ohm] Résistance des cables ;
        resGeometry = 'None';   % [m²] Type de résistance ;
        resSize = 0;            % [m²] Taille de la résistance ;
        Vq = 0;                 % [uV/Wm²] Coefficient de transductance ;
        lambda = 0;             % [W/mK] Conductivité thermique ;
        rho = 0;                % [kg/m³] Masse volumique ;
        cp = 0;                 % [J/kgK] Capacité thermique massique ;
        a = 0;                  % [m^2/s] Diffusivité thermique ;
        ell = 0;                % [m] Epaisseur de la plaque ;
        Ytr = 0;                % [uV/K] Coefficient du thermocouple ;
    end
    % ---------------------------------------------------------------------

    %% Méthodes publiques -------------------------------------------------
    methods

        % Contructeur de la classe
        function obj = sysDataType(name)
            if nargin == 1
                obj.name = name;
            end
        end

        % Initialise la valeur de la résistance choffante
        function obj = set.R(obj, R)
            if (R <= 0)
                error("La valeur de la résistance doit être " + ...
                    "positive et non nulle.");
            end
            obj.R = R;
        end

        % Initialise la valeur de la résistance des cables
        function obj = set.R_(obj, R_)
            if (R_ <= 0)
                error("La valeur de la résistance doit être " + ...
                    "positive et non nulle.");
            end
            obj.R_ = R_;
        end

        % Initialise la valeur de la surface de la résistance
        function obj = set.resSize(obj, resSize)
            if (resSize <= 0)
                error("La valeur de la surface doit être " + ...
                    "positive et non nulle.");
            end
            obj.resSize = resSize;
        end

        % Initialise la valeur de la conductivité thermique
        function obj = set.lambda(obj, lambda)
            if (lambda <= 0)
                error("La valeur de la conductivité thermique doit " + ...
                    "être positive et non nulle.");
            end
            obj.lambda = lambda;
            obj = obj.setDiffusivity;
        end

        % Initialise la valeur de la surface de la masse volumique
        function obj = set.rho(obj, rho)
            if (rho <= 0)
                error("La valeur de la masse volumique doit être " + ...
                    "positive et non nulle.");
            end
            obj.rho = rho;
            obj = obj.setDiffusivity;
        end

        % Initialise la capacité thermique
        function obj = set.cp(obj, cp)
            if (cp <= 0)
                error("La valeur du cp doit être positive et non " + ...
                    "nulle.");
            end
            obj.cp = cp;
            obj = obj.setDiffusivity;
        end

        % Initialise l'paisseur du thermocouple
        function obj = set.ell(obj, ell)
            if (ell <= 0)
                error("La valeur de l'paisseur doit être positive.");
            end
            obj.ell = ell;
        end

        % Convertion des données en tension par flux de chaleur
        function phi = toFlux(obj, in)
            % Pour le type 'tension', il va transformée la tension d'entrée 
            % dans la surface avant en flux de chaleur : il est supposé que
            % il n'y a pas des pertes dans la resistance (tous la puissance
            % sera transformée en chaleur) et le résultat est normalisée 
            % par rapport à sa surface. Pour le type 
            if strcmp(obj.type, 'both') || strcmp(obj.type,'flux')
                if obj.Vq == 0
                    error("La valeur du coefficient du transducteur " +...
                            "ne peut pas être nulle.");
                end
                phi = in/(obj.Vq * 1e-6);
            elseif strcmp(obj.type, 'tension')
                phi = (in/(obj.R+obj.R_)).^2 * obj.R / obj.takeResArea;
            elseif strcmp(obj.type, 'None')
                error("Le champs 'type' n'a pas été specifié.");
            end
        end

        % Configure la sortie du thermocouple
        function y = setOutput(obj, in)
            % Description 
            if obj.Ytr ~= 0
                y = in/(obj.Ytr*1e-6);
            else
                error("Le champs 'Ytr' pour le coefficient du " + ...
                    "thermocouple n'a pas été specifié.");
            end
        end

        % Prendre la surface perpendiculaire du thermocouple
        function S = takeArea(obj)
            % Description 
            if strcmp(obj.geometry, 'Cylinder')
                S = pi*(obj.size^2);
            elseif strcmp(obj.geometry, 'Parallelepiped')
                S = obj.size^2;
            end
        end

        % Prendre la surface perpendiculaire de la résistance
        function S = takeResArea(obj)
            % Description 
            if strcmp(obj.resGeometry, 'Circ')
                S = pi*(obj.resSize^2);
            elseif strcmp(obj.resGeometry, 'Square')
                S = obj.resSize^2;
            end
        end

    end
    % ---------------------------------------------------------------------

    %% Méthodes privées ---------------------------------------------------
    methods (Hidden=true)

        % Configure la diffusivité
        function obj = setDiffusivity(obj)
            % Function de configuration de la diffusivité.
            obj.a = obj.lambda/(obj.cp*obj.rho);
        end
        
    end
    % ---------------------------------------------------------------------
end