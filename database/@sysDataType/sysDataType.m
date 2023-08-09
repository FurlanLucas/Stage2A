classdef sysDataType
    %% sysDataType
    %
    % Cette classe permet d'avoir l'ensamble de tous les information liées
    % à chaque réalisation experimental.
    %
    %   Propritées :
    %
    %       Name : nom de l'analyse faite. Normalement, il codifie le
    %       système a être analisé et le type d'isolant qui a été utilisé ;
    %
    %       Geometry : géométrie du système analysé. Il peut être
    %       'Cylinder', dans ce cas l'analyse multidimentional utilisé
    %       sera 2D (axisimétrique), ou 'Cube' pour laquelle une analyse 3D
    %       sera utilisée ;
    %
    %       Size : taille du thermocouple en m. Pour une géométrie du type
    %       'Cylinder' il est le rayon du thermocouple, pour une géométrie
    %       du type 'Cube', il est la largeur ;
    %
    %       R : valeur de la résistance utilisé dans l'analyse en Ohms, à 
    %       compter avec les fils de connexion ;
    %
    %       R_ : valeur de la résistance des cables en Ohms ;
    %
    %       ResSize : taille de la résistance utilisé (pour l'analyse 
    %       multidimensionalle) en m. Pour une géométrie du type 
    %       'Cylinder', la résistance sera supposé circulaire est 
    %       << ResSize >> est son rayon. Pour une géométrie du type 'Cube', 
    %       la résistance sera supposé carré est << ResSize >> est sa 
    %       largeur.
    %
    %       Vq : coefficient de transductance du capteur de flux en 
    %       uVm²/W ;
    %
    %       lambda : conductivité thermique du thermocouple en W/mK ;
    %
    %       rho : masse volumique du thermocouple en kg/m³ ;
    %
    %       cp : capacité thermique massique du thermocouple en J/kgK ;
    %
    %       a : diffusivité thermique du thermocouple en m^2/s ;
    %
    %       ell : epaisseur du thermocouple en m. Il est defini comme la
    %       position en x du capteur ;
    %
    %       Y_tr_back : coefficient du thermocouple utilisé dans la face
    %       arrière (la face contraire à l'entrée de flux de chaleur) ;
    %
    %       Y_tr_front : coefficient du thermocouple utilisé dans la face
    %       avant (la même face dans laquelle est appliqué le e flux de 
    %       chaleur) ;
    %
    %   Méthodes :
    %
    %       takeArea : il prends la valeur de la surface du thermocouple en
    %       m perpendiculaire au flux de chaleur pour l'analyse 1D ; 
    %
    %       takeResArea : il prends la valeur de la surface de la 
    %       résistance en m pour l'analyse 1D ;
    %
    %       toFlux : il fait la conversion entre la tension mesuré en V et
    %       la variation de flux de chaleur en entrée en W/m² ;
    %
    %       setOutputFront : il fait la conversion entre la tension mesuré 
    %       en V et la variation de température réelle en °C pour la
    %       surface avant en utilisant Ytr_front ;
    %
    %       setOutputBack : il fait la conversion entre la tension mesuré 
    %       en V et la variation de température réelle en °C pour la
    %       surface arrière en utilisant Ytr_back ;
    %
    %
    %   OBS : la configuration de la diffusivité est faite automatiquement
    %   a chaque fois que la conductivité, la capacité ou la masse 
    %   volumique est configuré.
    %
    % See also takeArea, takeArea, takeResArea, setOutputFront,
    % setOutputBack, setOutputFront, 

    %% Proprietées --------------------------------------------------------
    properties
        Name = 'Empty';         % [-] Nom de l'analyse ;
        Geometry = 'None';      % [-] Type of the geometry ;
        Size = 0;               % [m] Lateral size of the thermocouple ;
        Type = 'None';          % [-] Type de mesure realisé en entrée ;
        R = 0;                  % [Ohm] Résistance choffante ;
        R_ = 0;                 % [Ohm] Résistance des cables ;
        ResSize = 0;            % [m²] Taille de la résistance ;
        Vq = 0;                 % [uVm²/W] Coefficient de transductance ;
        lambda = 0;             % [W/mK] Conductivité thermique ;
        rho = 0;                % [kg/m³] Masse volumique ;
        cp = 0;                 % [J/kgK] Capacité thermique massique ;
        ell = 0;                % [m] Epaisseur de la plaque ;
        Ytr_back = 0;           % [uV/K] Coeff. du thermocouple (arr.) ;
        Ytr_front = 0;          % [uV/K] Coeff. du thermocouple (avan.) ;
    end

    properties (SetAccess = private)
        a = 0;                  % [m^2/s] Diffusivité thermique ;
    end
    % ---------------------------------------------------------------------

    %% Méthodes publiques -------------------------------------------------
    methods

        % Contructeur de la classe
        function obj = sysDataType(name)
            if nargin == 1
                obj.Name = name;
            end
        end

        % Initialise la géométrie
        function obj = set.Geometry(obj, Geometry)
            if ~strcmp(Geometry, 'Cylinder') && ~strcmp(Geometry, 'Cube')
                error("La géométrie doit être << Cylinder >> ou << " + ...
                    "Cube >>.");
            end
            obj.Geometry = Geometry;
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
        function obj = set.ResSize(obj, ResSize)
            if (ResSize <= 0)
                error("La valeur de la surface doit être " + ...
                    "positive et non nulle.");
            end
            obj.ResSize = ResSize;
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
        phi = toFlux(obj, v)

        % Configure la sortie du thermocouple de la face avant
        y = setOutputFront(obj, in)

        % Configure la sortie du thermocouple de la face arrière
        y = setOutputBack(obj, in)

        % Prendre la surface perpendiculaire du thermocouple
        S = takeArea(obj)

        % Prendre la surface perpendiculaire de la résistance
        S = takeResArea(obj)

    end
    % ---------------------------------------------------------------------

    %% Méthodes non visiblées ---------------------------------------------
    methods (Hidden=true)

        % Configure la diffusivité
        function obj = setDiffusivity(obj)
            % Function de configuration de la diffusivité.
            obj.a = obj.lambda/(obj.cp*obj.rho);
        end
        
    end
    % ---------------------------------------------------------------------
end