classdef sysDataType
    %% sysDataType
    % Cette classe permet d'avoir l'ensamble de tous les information liées
    % à chaque réalisation experimental.

    %% Proprietées --------------------------------------------------------
    properties
        name = 'Empty';         % [-] Nom de l'analyse ;
        R = 0;                  % [Ohm] Résistance choffante ;
        R_ = 0;                 % [Ohm] Résistance des cables ;
        S_res = 0;              % [m] Rayon de la resistance ;
        lambda = 0;             % [W/mK] Conductivité thermique ;
        rho = 0;                % [kg/m³] Masse volumique ;
        cp = 0;                 % [J/kgK] Capacité thermique massique ;
        a = 0;                  % [m^2/s] Diffusivité thermique ;
        e = 0;                  % [m] Epaisseur de la plaque ;
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
        function obj = set.S_res(obj, S_res)
            if (S_res <= 0)
                error("La valeur de la surface doit être " + ...
                    "positive et non nulle.");
            end
            obj.S_res = S_res;
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
        function obj = set.e(obj, e)
            if (e <= 0)
                error("La valeur de l'paisseur doit être positive.");
            end
            obj.e = e;
        end

        % Convertion des données en tension par flux de chaleur
        function phi = toFlux(obj, V)
            % Il va transdormée la tension d'entrée dans la surface avant
            % en flux de chaleur : il est supposé que il n'y a pas des
            % pertes dans la resistance (tous la puissance sera transformée
            % en chaleur) et le résultat est normalisée par rapport à sa
            % surface.
            phi = (V/(obj.R+obj.R_)).^2 * obj.R / obj.S_res ;
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