function bodeOut = model_2d(dataIn, h, seriesOrder, varargin)
    %% model_1d
    %
    %   Analyse en 2D de la function transfert F(s) = phi(s)/theta(s)
    %   théorique, sans aproximation polynomial. Il utilise les données 
    %   qui sont disponibles dans dataIn, dedans le champs sysData.
    %
    %   Appels:
    %
    %       bodeOut = model_2d(dataIn, h) : prendre le diagramme de bode
    %       avec le modèle 1d de la transfert de chaleur en utilisant la
    %       valeur du coefficient de transfert termique h. L'ordre de la
    %       expantion en série est fixé à 6.
    %
    %       bodeOut = model_2d(dataIn, h, seriesOrder) : prendre le diagramme 
    %       de bode avec le modèle 1d de la transfert de chaleur en utilisant 
    %       la valeur du coefficient de transfert termique h. L'ordre de la 
    %       expantion en série est donnée par seriesOrder.;
    %
    %       bodeOut = model_2d(__, optons) : prendre des entrées
    %       optionnelles.
    %
    %   Entrées :
    % 
    %   - dataIn : variable thermalData avec le système qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs sysData dedans dataIn. Il peut aussi être utilisé comme une
    %   structure si il y a des champs nécessaires dedans ;
    %   - h : Valeur du coefficient de transfert thermique (pertes). Il est
    %   donnée comme un vecteur h = [hx2, hr2] ;
    %   - seriesOrder : numéro des termes dans la série en r.
    %
    %   Sorties :
    %   
    %   - bodeOut : structure avec le résultat de l'analyse qui contien les
    %   champs bodeOut.w avec les fréquences choisit, bodeOut.mag avec la
    %   magnitude et bodeOut.phase avec les données de phase. Les variables
    %   bodeOut.mag et bodeOut.phase sont des celulles 1x2 avec des valeurs
    %   pour la face arrière {1} et avant {2}.
    %
    %   Entrées optionnelles :
    %   
    %   - wmin : fréquence minimale pour l'analyse en rad/s ;
    %   - wmax : fréquence maximale pour l'analyse en rad/s ;
    %   - wpoints : numéro de points en fréquence a être analysés.
    %   
    % See also thermalData, sysDataType.

    %% Entrées et constantes

    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  

    %% Données optionales et autres paramètres

    % Test les argument optionelles
    for i=1:2:length(varargin)        
        switch varargin{i}
            % Fréquence minimale pour le diagramme de bode
            case 'wmin'
                wmin = varargin{i+1};

            % Fréquence maximale pour le diagramme de bode
            case 'wmax'      
                wmax = varargin{i+1};

            % Nombre des points pour le diagrame
            case 'wpoints'     
                wpoints = varargin{i+1};

            % Erreur
            otherwise
                error("Option << " + varargin{i} + "non disponible.");
        end
    end

    % Il verifie le type d'entrée
    if isa(dataIn, 'thermalData')
        lambda = dataIn.sysData.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.sysData.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.sysData.ell;       % [m] Epaisseur plaque ;
        Rmax = dataIn.sysData.Size;     % [m] Taille du thermocouple (r) ;
        R0 = dataIn.sysData.ResSize;    % [m] Taille de la resistance (r) ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
        Rmax = dataIn.Size;     % [m] Taille du thermocouple (r) ;
        R0 = dataIn.ResSize;    % [m] Taille de la resistance (r) ;
    else
        error("Entrée << dataIn >> non valide.");
    end

    % Prendre l'ordre pour la série
    if ~exist('seriesOrder', 'var')
        seriesOrder = 10;
    end

    %% Autres variables de l'analyses
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    % Conductivité thermique
    lambda_x = lambda;
    lambda_r = lambda;

    % Diffusivité thermique (x)
    a_x = a;

    % Position a être analysé en r
    r = 0;

    % Coefficient de transfert thermique
    hx2 = h(1); % Convection naturelle en x2
    hr2 = h(1); % Convection naturelle en r2

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

    %% Modèle théorique de F(s) en 2D 
    Fs_2D = {zeros(size(w)), zeros(size(w))};

    for n = 0:seriesOrder % Serie en y
        R = besselj(0, alpha(n+1)*r);

        % Calcule le facteur de correction de la serie int(Y)*int(Z)
        int_R = (R0/alpha(n+1)) * besselj(1, alpha(n+1)*R0);
    
        % Résolution en 1D (quadripôle)
        gamma = sqrt(1j*w/a_x + alpha(n+1)^2);
        C = lambda_x*gamma.*sinh(ell*gamma);
        B = (1./(lambda*gamma)) .* sinh(ell*gamma);
        A = cosh(ell*gamma); % D = A

        % Face arrière
        Fs_eval = 1./(C + A*hx2);
        Fs_2D{1} = Fs_2D{1} + Fs_eval * (R/Nalpha(n+1))*int_R;

        % Face avant
        Fs_eval = (A + B*hx2)./(C + A*hx2);
        Fs_2D{2} = Fs_2D{2} + Fs_eval * (R/Nalpha(n+1))*int_R;

    end

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag{1} = abs(Fs_2D{1});
    bodeOut.mag{2} = abs(Fs_2D{2});
    bodeOut.phase{1} = angle(Fs_2D{1});
    bodeOut.phase{2} = angle(Fs_2D{2});
    
end
