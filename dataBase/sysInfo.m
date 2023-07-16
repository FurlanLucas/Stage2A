%% sysInfo
% Fichier avec des information de chaque réalisation experimental. IL ne
% retourne pas des variables mais les données (sysData) sont estoquées dans
% le workspace.

%% Premier système analysé et configuré en tension ------------------------
% Première analyse faite avec le DAS configuré en tension. Le isolant
% utilisé a été une surface de bois. Le capteur de flux qui a été utilisé
% c'était le plus grande disponible (rayon de 30mm) avec un coeficient Vq
% de 7.86 uVm²/W.
sysData(1) = sysDataType('sys1_polBas'); % [-] Nom de l'analyse ;
sysData(1).geometry = 'Cylinder'; % [-] Type of the geometry ;
sysData(1).size = 37.5e-3;        % [m] Lateral size of the thermocouple ;
sysData(1).type = 'both';         % [-] Type des données enregistrées ;
sysData(1).R = 48.9;              % [Ohm] Résistance choffante ;
sysData(1).R_ = 0.4;              % [Ohm] Résistance des cables ;
sysData(1).resGeometry = 'Circ';  % [m²] Type de résistance ;
sysData(1).resSize = 30e-3;       % [m²] Taille de la résistance ;
sysData(1).Vq = 7.86;             % [uVm²/W] Coefficient de transductance ;
sysData(1).lambda = 15;           % [W/mK] Conductivité thermique ;
sysData(1).rho = 7900;            % [kg/m³] Masse volumique ;
sysData(1).cp = 500;              % [J/kgK] Capacité thermique massique ;
sysData(1).setDiffusivity;        % [m^2/s] Diffusivité thermique ;
sysData(1).ell = 10e-3;           % [m] Epaisseur du thermocouple ;
sysData(1).Ytr = 42;              % [uV/K] Coefficient du thermocouple ;

%% Deuxième système analysé et configuré en tension -----------------------
% Deuxième analyse faite avec le DAS configuré en tension. Le isolant
% utilisé a été une surface de bois. Le capteur de flux qui a été utilisé
% c'était celui avec un rayon de 20mm et un coeficient Vq de 3.32 uVm²/W.
sysData(2) = sysDataType('sys2_polBas'); % [-] Nom de l'analyse ;
sysData(2).geometry = 'Cylinder'; % [-] Type of the geometry ;
sysData(2).size = 37.5e-3;        % [m] Lateral size of the thermocouple ;
sysData(2).type = 'both';         % [-] Type des données enregistrées ;
sysData(2).R = 16;                % [Ohm] Résistance choffante ;
sysData(2).R_ = 0.2;              % [Ohm] Résistance des cables ;
sysData(2).resGeometry = 'Square';% [m²] Type de résistance ;
sysData(2).resSize = 30e-3;       % [m²] Taille de la résistance ;
sysData(2).Vq = 3.32;             % [uVm²/W] Coefficient de transductance ;
sysData(2).lambda = 15;           % [W/mK] Conductivité thermique ;
sysData(2).rho = 7900;            % [kg/m³] Masse volumique ;
sysData(2).cp = 500;              % [J/kgK] Capacité thermique massique ;
sysData(2).setDiffusivity;        % [m^2/s] Diffusivité thermique ;
sysData(2).ell = 5e-3;            % [m] Epaisseur du thermocouple ;
sysData(2).Ytr = 42;              % [uV/K] Coefficient du thermocouple ;
