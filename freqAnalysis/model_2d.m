function bodeOut = model_2d(dataIn, h, seriesOrder)
    %% MODEL_1D
    %
    %   Analyse en 1D de la function transfert F(s) = phi(s)/theta(s). IL
    %   utilise les données qui sont disponibles dans dataIn, dedans le
    %   champs UserData (regardez aussi iddata).

    %% Entrées et constantess

    % Il verifie le type d'entrée
    if isa(dataIn, 'iddata')
        lambda = dataIn.UserData.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.UserData.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.UserData.ell;       % [m] Epaisseur plaque ;
        Rmax = dataIn.UserData.size;     % [m] Taille du thermocouple (y) ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
        Rmax = dataIn.size;     % [m] Taille du thermocouple (y) ;
    else
        error("Entrée 'dataIn' non valide.");
    end

    % Conductivité thermique
    lambda_x = lambda;
    lambda_r = lambda;

    % Diffusivité thermique (x)
    a_x = a;

    % Position a être analysé
    r = 1e-4;

    % Coefficient de transfert thermique
    hx2 = h(1); % Convection naturelle en x2
    hr2 = h(1); % Convection naturelle en r2

    % Paramètres de la simulation et données
    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    %% Solutions de l'équation transcendente

    % Prendre les solutions pour alpha_n (dans la direction y)
    load("J_roots.mat", 'J0', 'J1');
    
    f = @(alpha_n) hr2*besselj(0,alpha_n*Rmax) - ...
        lambda_r*besselj(1,alpha_n*Rmax).*alpha_n;
    
    alpha = zeros(seriesOrder+mod(seriesOrder,2)+1, 1);
    
    alpha(1) = bissec(f, 0, J0(1)/Rmax);
    alpha(2) = bissec(f, J1(1)/Rmax, J0(2)/Rmax);
    for i = 3:2:seriesOrder+mod(seriesOrder,2)+1
       alpha(i) = bissec(f, J1(i-1)/Rmax, J0(i)/Rmax);
       alpha(i+1) = bissec(f, J1(i)/Rmax, J0(i+1)/Rmax);
    end
    alpha = alpha(1:seriesOrder+1);
    Nalpha = ((Rmax^2) / 2) * (besselj(0, alpha*Rmax) .^ 2);

    %% Modèle théorique de F(s) en 3D
    Fs_2D = zeros(size(w));  % Vecteur avec des solutions

    for n = 0:seriesOrder % Serie en y
        R = besselj(0, alpha(n+1)*r);
    
        % Résolution en 1D
        gamma = sqrt(1j*w/a_x + alpha(n+1)^2);
        C = lambda_x*gamma.*sinh(ell*gamma);
        A = cosh(ell*gamma);
        Fs_eval = 1./(C + A*hx2);

        % Calcule le facteur de correction de la serie int(Y)*int(Z)
        int_R = (Rmax/alpha(n+1)) * besselj(1, alpha(n+1)*Rmax);

        % Some les fonctions (serie en y et en z)
        Fs_2D = Fs_2D + Fs_eval * ...
            (R/Nalpha(n+1))*int_R;

    end

    % Diagramme de bode
    mag_th = abs(Fs_2D);
    phase_th = angle(Fs_2D);

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = mag_th;
    bodeOut.phase = phase_th;
    
end
