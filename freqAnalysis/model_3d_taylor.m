function [bodeOut, Fs_taylor] = model_3d_taylor(dataIn, h, seriesOrder, ...
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
        Ly = dataIn.UserData.size;       % [m] Taille du thermocouple (y) ;
        Lz = dataIn.UserData.size;       % [m] Taille du thermocouple (z) ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
        Ly = dataIn.size;       % [m] Taille du thermocouple (y) ;
        Lz = dataIn.size;       % [m] Taille du thermocouple (z) ;
    else
        error("Entrée 'dataIn' non valide.");
    end

    % Conductivité thermique
    lambda_x = lambda;
    lambda_y = lambda;
    lambda_z = lambda;

    % Diffusivité thermique (x)
    a_x = a;

    % Coefficient de transfert thermique
    hx2 = h(1); % Convection naturelle en X2
    hy1 = h(2); % Convection naturelle en y1
    hy2 = h(3); % Convection naturelle en y2
    hz1 = h(4); % Convection naturelle en z1
    hz2 = h(5); % Convection naturelle en z2

    % Nombres de Biot
    Hy1 = hy1*Ly/lambda_y; % Convection naturelle en y1
    Hy2 = hy2*Ly/lambda_y; % Convection naturelle en y2
    Hz1 = hz1*Lz/lambda_z; % Convection naturelle en z1
    Hz2 = hz2*Lz/lambda_z; % Convection naturelle en z2

    % Position perpendiculaire
    y = Ly/2;
    z = Lz/2;

    % Prendre l'ordre pour Taylor
    if ~exist('taylorOrder', 'var')
        taylorOrder = padeOrder;
    end
    
    % Paramètres de la simulation et données
    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    % Autres paramètres
    correc = 1e-8;            % [-] Paramètre de correction numérique ;

    %% Solutions de l'équation transcendente

    % Prendre les solutions pour alpha_n (dans la direction y)
    alpha = zeros(1, seriesOrder+1);
    f = @(alpha) cot(alpha*Ly) - ...
            ((lambda_y*alpha).^2 - hy1*hy2)./(lambda_y*alpha*(hy1+hy2));
    for i=0:seriesOrder
        alpha(i+1) = bissec(f, (i+correc)*pi/Ly, (i+1-correc)*pi/Ly);
    end
    Nalpha = (1./(2*Ly*alpha.^2)).*( Hy1 + (Hy1^2 + (alpha*Ly).^2) .* ...
        (1 + Hy2./(Hy2^2 + (alpha*Ly).^2)) );
    
    % Prendre les solutions pour beta_m (dans la direction z)
    beta = zeros(1, seriesOrder+1);
    f = @(beta) cot(beta*Lz) - ...
            ((lambda_z*beta).^2 - hz1*hz2)./(lambda_z*beta*(hz1+hz2));
    for i=0:seriesOrder
        beta(i+1) = bissec(f, (i+correc)*pi/Lz, (i+1-correc)*pi/Lz);
    end
    Mbeta = (1./(2*Lz*beta.^2)).*( Hz1 + (Hz1^2 + (beta*Lz).^2) .* ...
        (1 + Hz2./(Hz2^2 + (beta*Lz).^2)) );

    %% Approximation de Taylor pour le modèle (avec des pertes)

    Fs_taylor_ev = zeros(size(w));  % Vecteur avec des solutions
    Fs_taylor = cell(seriesOrder^2, 1); % Fonction de transfert
    norder = taylorOrder:-1:0;

    % approximation pour e^(x) = P(xi)/Q(xi)
    P = (1/2).^norder ./ factorial(norder); % Aproximation e^(x) = P(xi)/Q(xi)
    Q = (-1/2).^norder ./ factorial(norder); % Aproximation e^(x) = P(xi)/Q(xi)
    A = [lambda_x/(2*ell), hx2/2]; % Polinôme en xi
    B = [-lambda_x/(2*ell), hx2/2]; % Polinôme en xi

    pos = 1;
    for n = 0:seriesOrder % Serie en y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:seriesOrder % Serie en z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);

            % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
            N = conv(P,Q); 
            D = conv(conv(P,P), A) + conv(conv(Q,Q), B);
        
            % Passe à la variable de Laplace s = (a/e^2)xi
            N = changeVariable(N(mod(fliplr(1:length(N)),2)==1), ...
                [ell^2/a_x (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);
            D = changeVariable(D(mod(fliplr(1:length(D)),2)==1), ...
                [ell^2/a_x (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);
            N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)
        
            % Diagramme de bode
            Fs_eval = polyval(N,w*1j)./polyval(D,w*1j);

            % Calcule le facteur de correction de la serie int(Y)*int(Z)
            if alpha(n+1) == 0
                int_Y = Ly;
            else
                int_Y = -sin(alpha(n+1)*Ly)/alpha(n+1) + ...
                    (hy1/(alpha(n+1)*lambda_x)) * ...
                    (cos(alpha(n+1)*Ly)/alpha(n+1) - 1/alpha(n+1));
            end
            if beta(m+1) == 0
                int_Z = Lz;
            else
                int_Z = -sin(beta(m+1)*Lz)/beta(m+1) + ...
                    (hz1/(beta(m+1)*lambda_z)) * ...
                    (cos(beta(m+1)*Lz)/beta(m+1) - 1/beta(m+1));
            end

            % Some les fonctions (serie en y et en z)
            Fs_taylor_ev = Fs_taylor_ev + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z*int_Y;

            % Fonction de transfert
            Fs_taylor{pos} = tf(N,D) * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z*int_Y;
            pos = pos+1;
        end
    end

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = abs(Fs_taylor_ev);
    bodeOut.phase = angle(Fs_taylor_ev);  
    
end
