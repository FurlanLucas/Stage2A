%% sysInfo
% Fichier avec des information de chaque réalisation experimental. IL ne
% retourne pas des variables mais les données (sysData) sont estoquées dans
% le workspace.

%% Premier système analysé avec tension -----------------------------------
sysData(1) = sysDataType('sys1_isoPla'); % [-] Nom de l'analyse ;
sysData(1).type = 'tension';        % [-] Type des données enregistrées ;
sysData(1).R = 48.9;                % [Ohm] Résistance choffante ;
sysData(1).R_ = 0.4;                % [Ohm] Résistance des cables ;
sysData(1).S_res = pi*(30e-3^2);    % [m] Rayon de la resistance ;
sysData(1).lambda = 15;             % [W/mK] Conductivité thermique ;
sysData(1).rho = 7900;              % [kg/m³] Masse volumique ;
sysData(1).cp = 500;                % [J/kgK] Capacité thermique massique ;
sysData(1).setDiffusivity;          % [m^2/s] Diffusivité thermique ;
sysData(1).e = 10e-3;               % [m] Epaisseur de la plaque ;

%% Premier système analysé directement (flux) -----------------------------
sysData(2) = sysDataType('sys1_isoFlu'); % [-] Nom de l'analyse ;
sysData(2).type = 'both';        % [-] Type des données enregistrées ;
sysData(2).R = 48.9;             % [Ohm] Résistance choffante ;
sysData(2).R_ = 0.4;             % [Ohm] Résistance des cables ;
sysData(2).S_res = pi*(30e-3^2); % [m] Rayon de la resistance ;
sysData(2).Vq = 3.32;            % [uV/Wm²] Coefficient de transductance ;
sysData(2).lambda = 15;          % [W/mK] Conductivité thermique ;
sysData(2).rho = 7900;           % [kg/m³] Masse volumique ;
sysData(2).cp = 500;             % [J/kgK] Capacité thermique massique ;
sysData(2).setDiffusivity;       % [m^2/s] Diffusivité thermique ;
sysData(2).e = 10e-3;            % [m] Epaisseur de la plaque ;

%% Deuxième système analysé (composite ?) ---------------------------------
sysData(3) = sysDataType('sys1_polBas'); % [-] Nom de l'analyse ;
sysData(3).type = 'both';        % [-] Type des données enregistrées ;
sysData(3).R = 16;               % [Ohm] Résistance choffante ;
sysData(3).R_ = 0.2;             % [Ohm] Résistance des cables ;
sysData(3).S_res = 30e-3^2;      % [m] Rayon de la resistance ;
sysData(3).Vq = 7.86;            % [uVm²/W] Coefficient de transductance ;
sysData(3).lambda = 15;        % [W/mK] Conductivité thermique ;
sysData(3).rho = 7900;           % [kg/m³] Masse volumique ;
sysData(3).cp = 50;             % [J/kgK] Capacité thermique massique ;
sysData(3).setDiffusivity;       % [m^2/s] Diffusivité thermique ;
sysData(3).e = 10e-3;            % [m] Epaisseur de la plaque ;
sysData(3).Ytr = 42;             % [uV/K] Coefficient du thermocouple ;

%% Deuxième système analysé (composite ?) ---------------------------------
sysData(4) = sysDataType('sys2_polBas'); % [-] Nom de l'analyse ;
sysData(4).type = 'both';        % [-] Type des données enregistrées ;
sysData(4).R = 16;               % [Ohm] Résistance choffante ;
sysData(4).R_ = 0.2;             % [Ohm] Résistance des cables ;
sysData(4).S_res = 30e-3^2;      % [m] Rayon de la resistance ;
sysData(4).Vq = 3.32;            % [uVm²/W] Coefficient de transductance ;
sysData(4).lambda = 15;        % [W/mK] Conductivité thermique ;
sysData(4).rho = 7900;           % [kg/m³] Masse volumique ;
sysData(4).cp = 500;             % [J/kgK] Capacité thermique massique ;
sysData(4).setDiffusivity;       % [m^2/s] Diffusivité thermique ;
sysData(4).e = 5e-3;             % [m] Epaisseur de la plaque ;
sysData(4).Ytr = 42;             % [uV/K] Coefficient du thermocouple ;
