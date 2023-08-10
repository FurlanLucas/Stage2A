function bodeOut = model_1d(dataIn, h, varargin)
    %% model_1d
    %
    %   Analyse en 1D de la function transfert F(s) = phi(s)/theta(s)
    %   théorique, sans aproximation polynomial. Il utilise les données 
    %   qui sont disponibles dans dataIn, dedans le champs sysData.
    %
    %   Appels:
    %
    %       bodeOut = model_1d(dataIn, h) : prendre le diagramme de bode
    %       avec le modèle 1d de la transfert de chaleur en utilisant la
    %       valeur du coefficient de transfert termique h ;
    %
    %       bodeOut = model_1d(__, optons) : prendre des entrées
    %       optionnelles.
    %
    %   Entrées :
    % 
    %   - dataIn : variable thermalData avec le système qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs sysData dedans dataIn. Il peut aussi être utilisé comme une
    %   structure si il y a des champs necessaires dedans ;
    %   - h : Valeur du coefficient de transfert thermique (pertes).
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
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Conductivité thermique ;
        a = dataIn.a;           % [m^2/s] Diffusivité thermique ;
        ell = dataIn.ell;       % [m] Epaisseur plaque ;
    else
        error("Entrée << dataIn >> non valide.");
    end

    %% Autres variables de l'analyses
    w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur des fréq.

    %% Modèle théorique de F(s) en 1D
    
    % Résolution de l'équation en 1D pour les fréquences w
    k = sqrt(w*1j/a); 
    C = lambda*k.*sinh(ell*k);
    B = (1./(lambda*k)) .* sinh(ell*k);
    A = cosh(ell*k); % D = A
    
    % Face arrière
    Fs_th = 1./(C + A*h);
    mag_th{1} = abs(Fs_th);
    phase_th{1} = angle(Fs_th);

    % Face avant
    Fs_th = (A + B*h)./(C + A*h);
    mag_th{2} = abs(Fs_th);
    phase_th{2} = angle(Fs_th);

    %% Résultats
    bodeOut.w = w;
    bodeOut.mag = mag_th;
    bodeOut.phase = phase_th;    
    
end