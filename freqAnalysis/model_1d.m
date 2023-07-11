function bodeOut = model_1d(dataIn, h)
    %% MODEL_1D
    %
    %   Analyse en 1D de la function transfert F(s) = phi(s)/theta(s). IL
    %   utilise les données qui sont disponibles dans dataIn, dedans le
    %   champs UserData (regardez aussi iddata).

    %% Entrées et constantes

    % Il verifie le type d'entrée
    if isa(dataIn, 'iddata')
        lambda = dataIn.UserData.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.UserData.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.UserData.ell;       % [m] Epaisseur plaque ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
    end

    % Paramètres de la simulation et données
    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    %% Modèle théorique de F(s) en 1D
    
    % Résolution de l'équation en 1D pour les fréquences w
    k = sqrt(w*1j/a); 
    C = lambda*k.*sinh(ell*k);
    A = cosh(ell*k);
    
    Fs_th = 1./(C + A*h); % Modèle théorique avec des pertes
    mag_th = abs(Fs_th);
    phase_th = angle(Fs_th);

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = mag_th;
    bodeOut.phase = phase_th;    
    
end