function [bodeOut, Fs_taylor] = model_2d_taylor(dataIn, h, seriesOrder, ...
    taylorOrder)
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
        Rmax = dataIn.UserData.size;     % [m] Taille du thermocouple (y) ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
        Rmax = dataIn.size;     % [m] Taille du thermocouple (y) ;
    else
        error("Entrée 'dataIn' non valide.");
    end
    %r0 = Rmax;
    %r0 = 35.6e-3;
    r0 = dataIn.UserData.resSize;

    % Conductivité thermique
    lambda_x = lambda;
    lambda_r = lambda;

    % Diffusivité thermique (x)
    a_x = a;

    % Position a être analysé
    r_star = 0;

    % Coefficient de transfert thermique
    hx2 = h(1); % Convection naturelle en x2
    hr2 = h(1); % Convection naturelle en r2

    % Prendre l'ordre pour Taylor
    if ~exist('taylorOrder', 'var')
        taylorOrder = 10;
    end
    
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
    
    alpha = zeros(seriesOrder+1, 1);
    
    alpha(1) = bissec(f, 0, J0(1)/Rmax);
    for i = 1:seriesOrder
       alpha(i+1) = bissec(f, J1(i)/Rmax, J0(i+1)/Rmax);
    end

    % for i = 1:seriesOrder+1
    %     f = @(x) x.*besselj(0, alpha(i)*x).^2;
    %     Malpha(i) = integral(f, 0, Rmax);
    % end

    Malpha = (besselj(0, alpha*Rmax) .^ 2).*((Rmax * alpha).^2 + ...
        (Rmax * hr2 / lambda_r)^2)./(2*(alpha.^2));

    %% Approximation de Pade pour le modèle (avec des pertes)

    Fs_taylor_ev = zeros(size(w));  % Vecteur avec des solutions
    Fs_taylor = cell(seriesOrder+1, 1); % Fonction de transfert
    norder = taylorOrder:-1:0;

    % Approximation pour e^(x) = P(xi)/Q(xi)
    P = (1/2).^norder ./ factorial(norder); % Aproximation e^(x) = P(xi)/Q(xi)
    Q = (-1/2).^norder ./ factorial(norder); % Aproximation e^(x) = P(xi)/Q(xi)
    A = [lambda_x/(2*ell), hx2/2]; % Polinôme en xi
    B = [-lambda_x/(2*ell), hx2/2]; % Polinôme en xi

    for n = 0:seriesOrder % Serie en r
        R = besselj(0, r_star*alpha(n+1));

        % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
        N = conv(P,Q); 
        D = conv(conv(P,P), A) + conv(conv(Q,Q), B);

        % Passe à la variable de Laplace s = (a/e^2)xi
        N = changeVariable(N(mod(fliplr(1:length(N)),2)==1), ...
            [ell^2/a_x (alpha(n+1)*ell)^2]);
        D = changeVariable(D(mod(fliplr(1:length(D)),2)==1), ...
            [ell^2/a_x (alpha(n+1)*ell)^2]);
        N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)

        % Diagramme de bode
        Fs_eval = polyval(N,w*1j)./polyval(D,w*1j);

        % Calcule le facteur de correction de la serie int(Y)*int(Z)
        int_R = (r0/alpha(n+1)) * besselj(1, alpha(n+1)*r0);
        % f = @(x) x.*besselj(0, alpha(n+1)*x);
        % int_R = integral(f, 0, r0);

        % Some les fonctions (serie en y et en z)
        Fs_taylor_ev = Fs_taylor_ev + Fs_eval * (R/Malpha(n+1))*int_R;
        
        % Fonction de transfert
        Fs_taylor{n+1} = tf(N,D) * (R/Malpha(n+1))*int_R;
    end

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = abs(Fs_taylor_ev);
    bodeOut.phase = angle(Fs_taylor_ev);    
end
