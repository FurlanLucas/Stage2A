%% sysInfo
% Fichier avec des information de chaque réalisation experimental. IL ne
% retourne pas des variables mais les données (sysData) sont estoquées dans
% le workspace.

%% ------------------------------------------------------------------------
sysData(1) = sysDataType('sys1_isoPla'); % [-] Nom de l'analyse ;
sysData(1).R = 48.9;                % [Ohm] Résistance choffante ;
sysData(1).R_ = 0.4;                % [Ohm] Résistance des cables ;
sysData(1).S_res = pi*(30e-3^2);    % [m] Rayon de la resistance ;
sysData(1).lambda = 15;             % [W/mK] Conductivité thermique ;
sysData(1).rho = 7900;              % [kg/m³] Masse volumique ;
sysData(1).cp = 500;                % [J/kgK] Capacité thermique massique ;
sysData(1).setDiffusivity;          % [m^2/s] Diffusivité thermique ;
sysData(1).e = 10e-3;               % [m] Epaisseur de la plaque ;

%% ------------------------------------------------------------------------