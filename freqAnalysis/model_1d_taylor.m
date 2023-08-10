function [bodeOut, Fs_taylor] = model_1d_taylor(dataIn, h, taylorOrder, varargin)
    %% model_1d_taylor
    %
    %   Analyse en 1D de la function transfert F(s) = phi(s)/theta(s)
    %   théorique, avec une aproximation polynomial de Taylor. Il utilise 
    %   les données qui sont disponibles dans dataIn, dedans le champs
    %   sysData.
    %
    %   Appels:
    %
    %       [bodeOut, Fs_pade] = model_1d_taylor(dataIn, h) : prendre le
    %       diagramme de bode et de la fonction de transfert avec le modèle 1d 
    %       de la transfert de chaleur en utilisant la valeur du coefficient 
    %       de transfert termique h et une approximation de Taylor d'ordre 10.
    %       
    %       [bodeOut, Fs_pade] = model_1d_taylor(dataIn, h, padeOrder) : prendre 
    %       le diagramme de bode et de la fonction de transfert avec le modèle 
    %       1d de la transfert de chaleur en utilisant la valeur du coefficient 
    %       de transfert termique h et une approximation de Pade d'ordre 
    %       padeOrder.
    %
    %       [bodeOut, Fs_pade] = model_1d_pade(__, optons) : prendre des entrées
    %       optionnelles.
    %
    %   Entrées :
    % 
    %   - dataIn : variable thermalData avec le système qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs sysData dedans dataIn. Il peut aussi être utilisé comme une
    %   structure si il y a des champs necessaires dedans ;
    %   - h : Valeur du coefficient de transfert thermique (pertes) ;
    %   - padeOrder : ordre de l'approximation de Pade.
    %
    %   Sorties :
    %   
    %   - bodeOut : structure avec le résultat de l'analyse qui contien les
    %   champs bodeOut.w avec les fréquences choisit, bodeOut.mag avec la
    %   magnitude et bodeOut.phase avec les données de phase. Les variables
    %   bodeOut.mag et bodeOut.phase sont des celulles 1x2 avec des valeurs
    %   pour la face arrière {1} et avant {2}.
    %   - Fs_pade : function de transfert (variable tf) avec
    %   l'approximation de Pade. Il est une celulle 1x2 avec des résultats
    %   pour la face arrière {1} et avant {2}.
    %
    %   Entrées optionnelles :
    %   
    %   - wmin : fréquence minimale pour l'analyse en rad/s ;
    %   - wmax : fréquence maximale pour l'analyse en rad/s ;
    %   - wpoints : numéro de points en fréquence a être analysés.
    %   
    % See also thermalData, sysDataType, model_1d.

    %% Entrées et constantes

    wmin = 1e-3;              % [rad/s] Fréquence minimale pour le bode ;
    wmax = 1e2;               % [rad/s] Fréquence maximale pour le bode ;
    wpoints = 1000;           % [rad/s] Nombre des fréquences ;  

    %% Données optionales et autres paramètres

    % Il verifie le type d'entrée
    if isa(dataIn, 'thermalData')
        lambda = dataIn.sysData.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.sysData.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.sysData.ell;       % [m] Epaisseur plaque ;
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
    else
        error("Entrée << dataIn >> non valide.");
    end

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

    % Prendre l'ordre pour Taylor
    if ~exist('taylorOrder', 'var')
        taylorOrder = 10;
    end
    
    %% Autres variables de l'analyse
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    % Approximation de Pade
    n = taylorOrder:-1:0;
    P = poly((1/2).^n ./ factorial(n)); % Aproximation e^(x) = P(xi)/Q(xi)
    Q = poly((-1/2).^n ./ factorial(n)); % Aproximation e^(x) = P(xi)/Q(xi)

    %% Approximation de Taylor pour le modèle arrière (avec des pertes)

    % Polynômes de la fonction (ils ne sont pas des termes du quadripôle)
    A_ = poly([lambda/(2*ell), h/2]); % Polinôme en xi
    B_ = poly([-lambda/(2*ell), h/2]); % Polinôme en xi

    % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
    N = P * Q; % Numérateur
    D = (P*P*A_) + (Q*Q*B_); % Dénominateur

    % Passe à la variable de Laplace s = (a/e^2)xi
    N = N.odd.comp([ell^2/a 0]);
    D = D.odd.comp([ell^2/a 0]);    

    % Unicité de F(s) (d0 = 1)
    N.coef = N.coef/D.coef(end); 
    D.coef = D.coef/D.coef(end);
    
    % Diagramme de bode pour Pade
    F_approx_ev = N.evaluate(w*1j)./D.evaluate(w*1j);
    mag_taylor{1} = abs(F_approx_ev);
    phase_taylor{1} = angle(F_approx_ev);
    Fs_taylor{1} = tf(N.coef, D.coef);

    %% Approximation de Taylor pour le modèle avant (avec des pertes)

    % Polynômes de la fonction (ils ne sont pas des termes du quadripôle)
    A_ = poly([lambda/ell, h]); % Polinôme en xi
    B_ = poly([lambda/ell, -h]); % Polinôme en xi
    C_ = poly([(lambda/ell)^2, h*lambda/ell 0]); % Polinôme en xi
    D_ = poly([-(lambda/ell)^2, h*lambda/ell 0]); % Polinôme en xi

    % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
    N = (P*P*A_) + (Q*Q*B_); % Numérateur
    D = (P*P*C_) + (Q*Q*D_); % Dénominateur

    % Passe à la variable de Laplace s = (a/e^2)xi
    N = N.even.comp([ell^2/a 0]);
    D = D.even.comp([ell^2/a 0]);    

    % Unicité de F(s) (d0 = 1)
    N.coef = N.coef/D.coef(end); 
    D.coef = D.coef/D.coef(end);
    
    % Diagramme de bode pour Pade
    F_approx_ev = N.evaluate(w*1j)./D.evaluate(w*1j);
    mag_taylor{2} = abs(F_approx_ev);
    phase_taylor{2} = angle(F_approx_ev);
    Fs_taylor{2} = tf(N.coef, D.coef);

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = mag_taylor;
    bodeOut.phase = phase_taylor;
    
end