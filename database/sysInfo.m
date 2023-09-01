%% sysInfo
% File with all the information of the systems that have been analysed. It
% doesn't return any variable, but they are loaded to the current
% workspace.

%% First system analysed with an homogenous material ------------------------------
% First system analysed with DAS configured in tension mode. The insulant
% used was the ___ material. The heat flux sensor used was the bigger one
% avaiablem (radius of 30mm) with a coefficient Vq = 7.86 cV/(W/m²). A
% second thermocouple was used in the front face.

sysData(1) = sysDataType('sys1_isoBas'); % [-] Analysis name
sysData(1).Geometry = 'Cylinder'; % [-] Type of the geometry
sysData(1).Size = 37.5e-3;        % [m] Lateral size of the thermocouple
sysData(1).R = 48.9;              % [Ohm] Heat resistance value
sysData(1).R_ = 0.4;              % [Ohm] Cables resistence
sysData(1).ResSize = 30e-3;       % [m²] Resistence size
sysData(1).Vq = 7.86;             % [uVm²/W] Transconductance coefficient
sysData(1).lambda = 15;           % [W/mK] Thermal conductivity
sysData(1).rho = 7900;            % [kg/m³] Density
sysData(1).cp = 500;              % [J/kgK] Specific heat in constant pressure
sysData(1).ell = 5e-3;            % [m] Termocouple depth
sysData(1).ell2 = 10e-3;          % [m] Termocouple depth (hole)
sysData(1).rH = 10e-3;            % [m] Hole radious
sysData(1).Ytr_back = 42;         % [uV/K] Thermocouple coefficient (rear)
sysData(1).Ytr_front = 42;        % [uV/K] Thermocouple coefficient (back)

%% Deuxième système analysé et configuré en tension -----------------------
% First system analysed with DAS configured in tension mode. The insulant
% used was the ___ material. The heat flux sensor used was the bigger one
% avaiablem (radius of 30mm) with a coefficient Vq = 3.32 cV/(W/m²). A
% second thermocouple was used in the front face.
sysData(2) = sysDataType('sys2_isoBas'); % [-] Analysis name;
sysData(2).Geometry = 'Cylinder'; % [-] Type of the geometry
sysData(2).Size = 37.5e-3;        % [m] Lateral size of the thermocouple
sysData(2).R = 48.9;              % [Ohm] Heat resistance value
sysData(2).R_ = 0.35;             % [Ohm] Cables resistence
sysData(2).ResSize = 30e-3;       % [m²] Resistence size
sysData(2).Vq = 3.32;             % [uVm²/W] Transconductance coefficient
sysData(2).lambda = 15;           % [W/mK] Thermal conductivity
sysData(2).rho = 7900;            % [kg/m³] Density
sysData(2).cp = 500;              % [J/kgK] Specific heat in constant pressure
sysData(2).ell = 5e-3;            % [m] Termocouple depth
sysData(2).ell2 = 10e-3;          % [m] Termocouple depth (hole)
sysData(2).rH = 10e-3;            % [m] Hole radious
sysData(2).Ytr_back = 42;         % [uV/K] Thermocouple coefficient (rear)
sysData(2).Ytr_front = 42;        % [uV/K] Thermocouple coefficient (back)
