classdef sysDataType
    %% sysDataType
    %
    % Class that has all the information related to each system analysed,
    % such as thermal properties, geometry dimension and sensor
    % coefficients. The front surface is defined as the surface for x=0 and
    % the rear face for x=ell.
    %
    % Properties
    %
    %   Name: analysis name that codifies the system and tipe of insulating
    %   used;
    %
    %   Geometry: sysmtem geometry. It can be 'Cylinder' for which the
    %   analysis will be 2D (axisymmetric cylindrical coordenates) or
    %   'Cube' for wich the analysis will be 3D in regular cartesian
    %   coordenate system. If its 'None', a error will be thrown.
    %
    %   Size: termocouple size in meters. If the geometry is 'Cylinder',
    %   the size is supposed to be the radious of the termocouple. For a
    %   'Cube' geometry, it is supposed to be the lateral length of the
    %   termocouple;
    %
    %   R: resistence value in Ohms, without the cables resistence;
    %
    %   R_: resistance value of the cables in Ohms, without the heat 
    %   resistence itself;
    %
    %   Vq: transductance coefficient for the heat flux sensor in
    %   uV/(W/m²);
    %
    %   lambda: thermal conductivity of the material in W/mK;
    %
    %   rho: material density in kg/m³;
    %
    %   cp: specific heat with constant pressure in J/kgK;
    %
    %   a: thermocouple thermal diffusivity in m^2/s. This value is
    %   calculated with lambda/(cp*rho) and can not be changed. A new value
    %   is calculated each time the conductivity, density or the specific
    %   heat changes.
    %
    %   ell: depth of the thermocouple (x axis) in meters;
    %
    %   Y_tr_back: thermocouple coefficient in uV/K for the rear face;
    %
    %   Y_tr_front: thermocouple coefficient in uV/K for the front face.
    %
    % Methods
    %
    %   takeArea: takes the area of a thermocouple surface perpendicular 
    %   with respect to the heat flux in m²;
    %
    %   takeResArea : takes the resistance area in m²;
    %
    %   toFlux : does the conversion between tension in V and heat flux 
    %   measured W/m²;
    %
    %   setOutputFront: does the conversion between tension in V and the
    %   temperature change measured in the front face in °C.
    %
    %   setOutputBack: does the conversion between tension in V and the
    %   temperature change measured in the rear face in °C.
    %
    % See also takeArea, takeArea, takeResArea, setOutputFront,
    % setOutputBack, setOutputFront.

    %% Proprerties ----------------------------------------------------------------
    properties
        Name = 'Empty';         % [-] Analysis name
        Geometry = 'None';      % [-] Geometry type
        Size = 0;               % [m] Lateral size of the thermocouple
        R = 0;                  % [Ohm] Heat resistance value
        R_ = 0;                 % [Ohm] Cables resistance value
        ResSize = 0;            % [m] Resistance size
        Vq = 0;                 % [uVm²/W] Heat flux sensor coefficient
        lambda = 0;             % [W/mK] Thermal conductivity
        rho = 0;                % [kg/m³] Termocouple dentsity
        cp = 0;                 % [J/kgK] Specific heat with constant pressure
        ell = 0;                % [m] Depth of the termocouple
        Ytr_back = 0;           % [uV/K] Thermocouple coefficient (rear)
        Ytr_front = 0;          % [uV/K] Thermocouple coefficient (front)
    end

    properties (SetAccess = private)
        a = 0;                  % [m^2/s] Thermal diffusivity
    end

    %% Methods --------------------------------------------------------------------
    methods

        % Class constructor
        function obj = sysDataType(name)
            if nargin == 1
                obj.Name = name;
            end
        end

        % Set geometry propertie
        function obj = set.Geometry(obj, Geometry)
            if ~strcmp(Geometry, 'Cylinder') && ~strcmp(Geometry, 'Cube') && ...
                    ~strcmp(Geometry, 'None')
                error("The geometry is not valid. It has to be either " + ...
                    "'Cylinder' or 'Cube'.");
            end
            obj.Geometry = Geometry;
        end

        % Set resistance value propertie
        function obj = set.R(obj, R)
            if (R <= 0)
                error("The resiste value has to be positive and non-zero.");
            end
            obj.R = R;
        end

        % Set cable resistance value propertie
        function obj = set.R_(obj, R_)
            if (R_ <= 0)
                error("The resiste value has to be positive and non-zero.");
            end
            obj.R_ = R_;
        end

        % Set the resistance size
        function obj = set.ResSize(obj, ResSize)
            if (ResSize <= 0)
                error("The resiste size has to be positive and non-zero.");
            end
            obj.ResSize = ResSize;
        end

        % Set the thermal conductivity
        function obj = set.lambda(obj, lambda)
            if (lambda <= 0)
                error("The conductivity has to be positive and" + ...
                    "non-zero.");
            end
            obj.lambda = lambda;
            obj = obj.setDiffusivity;
        end

        % Set the density value
        function obj = set.rho(obj, rho)
            if (rho <= 0)
                error("The density has to be positive and non-zero.");
            end
            obj.rho = rho;
            obj = obj.setDiffusivity;
        end

        % Set the specific heat
        function obj = set.cp(obj, cp)
            if (cp <= 0)
                error("The specific heat has to be positive and" + ...
                    "non-zero.");
            end
            obj.cp = cp;
            obj = obj.setDiffusivity;
        end

        % Set the depth value (x position)
        function obj = set.ell(obj, ell)
            if (ell <= 0)
                error("The depth has to be positive and non-zero.");
            end
            obj.ell = ell;
        end

        % Change tension into heat flux
        phi = toFlux(obj, v)

        % Change tension into temperature (front face)
        y = setOutputFront(obj, in)

        % Change tension into temperature (rear face)
        y = setOutputBack(obj, in)

        % Take thermocouple area
        S = takeArea(obj)

        % Take resistence area
        S = takeResArea(obj)

    end

    %% Hiden methods --------------------------------------------------------------
    methods (Hidden=true)

        % Diffusivity configuration
        function obj = setDiffusivity(obj)
            obj.a = obj.lambda/(obj.cp*obj.rho);
        end
        
    end
    % -----------------------------------------------------------------------------
end