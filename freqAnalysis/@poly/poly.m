classdef poly
    %% poly
    %
    % Cette classe permet de definir un polynôme et operer avec lui.
    %
    %   Propritées :
    %
    %       Coef : coefficients du polynôme, enregistré comme un vecteur
    %       ligne ou colune ;
    %
    %       order : ordre du polinôme, égale à length(coef) - 1 ;
    %
    %       Notes : informations de l'user.
    %
    %   Méthodes :
    %
    %       comp : prends la composition des deux polynômes, returné comme
    %       un polinôme il-même.
    %
    % See also comp.

    %% Proprietées --------------------------------------------------------
    properties
        coef = [];                % Coefficients du polinôme ;
        Notes = {};               % Notes de l'user ;
    end 

    properties (SetAccess = private)
        order = 0;                  % Ordre du polinôme ;
    end

    %% Méthodes -----------------------------------------------------------
    methods
        % Contructeur de la classe
        function obj = poly(coef)
            if nargin == 1
                obj.coef = coef;
            end
        end

        % Configuration de lordre
        function obj = set.coef(obj, coef)
            if iscolumn(coef) || isrow(coef) 
                obj.coef = coef;
                obj = obj.setOrder;
            else
                error("La taille du vecteur n'est pas la bonne.");
            end
        end

        function obj = setOrder(obj)
            obj.order = length(obj.coef)-1;
        end

        % Réécrit la fonction plus
        obj = plus(obj1, obj2);

        % Réécrit la fonction de multiplication
        objout = mtimes(objin1, objin2);

        % Réécrit le opérateur de puissance
        obj = mpower(obj1, obj2);

        % Composition des polynômes
        R = comp(obj, P);

        % Prendre les coefficients paires
        R = even(obj);

        % Prendre les coefficients impaires
        R = odd(obj);

        % Évalue le polynômes dans les points espécifiés
        R = evaluate(obj, in);

    end
end