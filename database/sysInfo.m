%% sysInfo
% File with all the information of the systems that have been analysed. It
% doesn't return any variable, but they are loaded to the current
% workspace.

%% First system analysed with an homogenous material ------------------------------
% First system analysed with DAS configured in tension mode. The insulant
% used was the ___ material. The heat flux sensor used was the bigger one
% avaiablem (radius of 30mm) with a coefficient Vq = 7.86 cV/(W/m²). A
% second thermocouple was used in the front face.

sysData(1) = sysDataType('sys1_isoBas'); % [-] Nom de l'analyse ;
sysData(1).Geometry = 'Cube'; % [-] Type of the geometry ;
sysData(1).Size = 37.5e-3;        % [m] Lateral size of the thermocouple ;
sysData(1).R = 48.9;              % [Ohm] Résistance choffante ;
sysData(1).R_ = 0.4;              % [Ohm] Résistance des cables ;
sysData(1).ResSize = 30e-3;       % [m²] Taille de la résistance ;
sysData(1).Vq = 7.86;             % [uVm²/W] Coefficient de transductance ;
sysData(1).lambda = 15;           % [W/mK] Conductivité thermique ;
sysData(1).rho = 7900;            % [kg/m³] Masse volumique ;
sysData(1).cp = 500;              % [J/kgK] Capacité thermique massique ;
sysData(1).ell = 10e-3;           % [m] Epaisseur du thermocouple ;
sysData(1).Ytr_back = 42;         % [uV/K] Coeff. du thermocouple (arr.) ;
sysData(1).Ytr_front = 42;        % [uV/K] Coeff. du thermocouple (avan.) ;

%% Deuxième système analysé et configuré en tension -----------------------
% Deuxième analyse faite avec le DAS configuré en tension. Le isolant
% utilisé a été une surface de bois. Le capteur de flux qui a été utilisé
% c'était celui avec un rayon de 20mm et un coeficient Vq de 3.32 uVm²/W.
% sysData(2) = sysDataType('sys2_isoBas'); % [-] Nom de l'analyse ;
% sysData(2).Geometry = 'Cylinder'; % [-] Type of the geometry ;
% sysData(2).Size = 37.5e-3;        % [m] Lateral size of the thermocouple ;
% sysData(2).Type = 'both';         % [-] Type des données enregistrées ;
% sysData(2).R = 16;                % [Ohm] Résistance choffante ;
% sysData(2).R_ = 0.2;              % [Ohm] Résistance des cables ;
% sysData(2).ResSize = 30e-3;       % [m²] Taille de la résistance ;
% sysData(2).Vq = 3.32;             % [uVm²/W] Coefficient de transductance ;
% sysData(2).lambda = 15;           % [W/mK] Conductivité thermique ;
% sysData(2).rho = 7900;            % [kg/m³] Masse volumique ;
% sysData(2).cp = 500;              % [J/kgK] Capacité thermique massique ;
% sysData(2).ell = 5e-3;            % [m] Epaisseur du thermocouple ;
% sysData(2).Ytr_back = 42;         % [uV/K] Coeff. du thermocouple (arr.) ;
% sysData(2).Ytr_front = 42;        % [uV/K] Coeff. du thermocouple (avan.) ;
