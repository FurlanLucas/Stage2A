function [bodeOut, Fs_pade] = model_1d_pade(dataIn, h, padeOrder)
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

    % Prendre l'ordre pour Taylor
    if ~exist('padeOrder', 'var')
        padeOrder = 10;
    end
    
    % Paramètres de la simulation et données
    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    % Approximation de Pade
    [Q, P] = padecoef(1, padeOrder); % Aproximation e^(x) = P(xi)/Q(xi)

    %% Approximation de Pade pour le modèle arrière (avec des pertes)
    A = [lambda/(2*ell), h/2]; % Polinôme en xi
    B = [-lambda/(2*ell), h/2]; % Polinôme en xi

    % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
    N = conv(P,Q); 
    D = conv(conv(P,P), A) + conv(conv(Q,Q), B);

    % Passe à la variable de Laplace s = (a/e^2)xi
    N = changeVariable(N(mod(fliplr(1:length(N)),2)==1), [ell^2/a 0]);
    D = changeVariable(D(mod(fliplr(1:length(D)),2)==1), [ell^2/a 0]);
    N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)
    
    % Diagramme de bode pour Pade
    F_approx_ev = polyval(N,w*1j)./polyval(D,w*1j);
    mag_pade{1} = abs(F_approx_ev);
    phase_pade{1} = angle(F_approx_ev);
    Fs_pade{1} = tf(N, D);

    %% Approximation de Pade pour le modèle avant (avec des pertes)
    A = [lambda/ell, h]; % Polinôme en xi
    B = [lambda/ell, -h]; % Polinôme en xi
    C = [(lambda/ell)^2, h*lambda/ell 0]; % Polinôme en xi
    D = [-(lambda/ell)^2, h*lambda/ell 0]; % Polinôme en xi

    % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
    N = conv(conv(P,P), A) + conv(conv(Q,Q), B);
    D = conv(conv(P,P), C) + conv(conv(Q,Q), D);

    % Passe à la variable de Laplace s = (a/e^2)xi
    N = changeVariable(N(mod(fliplr(1:length(N)),2)==0), [ell^2/a 0]);
    D = changeVariable(D(mod(fliplr(1:length(D)),2)==0), [ell^2/a 0]);
    N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)
    
    % Diagramme de bode pour Pade
    F_approx_ev = polyval(N,w*1j)./polyval(D,w*1j);
    mag_pade{2} = abs(F_approx_ev);
    phase_pade{2} = angle(F_approx_ev);
    Fs_pade{2} = tf(N, D);

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = mag_pade;
    bodeOut.phase = phase_pade;
    
end