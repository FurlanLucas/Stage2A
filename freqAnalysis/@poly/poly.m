classdef poly
    %% poly
    %
    % Class that defines a polynomial object.
    %
    % Properties
    %
    %   coef: polynomial coeficients. Could be set as a column or row
    %   vector;
    %
    %   order: polynomial order, defined as the number of coefficients -1;
    %
    %   Notes: user notes.
    %
    % Methods
    % 
    %   comp: take the composition between to polynomials as R(x)=Q(P(x));
    %
    %   odd: returns another polynomial with all the odd coefficients;
    %
    %   even: returns another polynomial with all the even coefficients;
    %
    %   evaluate: evaluate the polynomial in specified points.
    %
    % See also comp.

    %% Properties -----------------------------------------------------------------
    properties
        coef = [];                % Polynomial coefficients
        Notes = {};               % User notes
    end 

    properties (SetAccess = private)
        order = 0;                  % Ordre du polinôme ;
    end

    %% Methods --------------------------------------------------------------------
    methods
        % Class constructor
        function obj = poly(coef)
            if nargin == 1
                obj.coef = coef;
            end
        end

        % Order configuration
        function obj = set.coef(obj, coef)
            if iscolumn(coef) || isrow(coef) 
                obj.coef = coef;
                obj = obj.setOrder;
            else
                error("The input is not a vector size variable.");
            end
        end

        function obj = setOrder(obj)
            obj.order = length(obj.coef)-1;
        end

        % Overload of plus operator
        obj = plus(obj1, obj2);

        % Overload of mtimes operator
        objout = mtimes(objin1, objin2);

        % Overload mpower operator
        obj = mpower(obj1, obj2);

        % Defines the polynomial composition
        R = comp(obj, P);

        % Take all even coefficients
        R = even(obj);

        % Take all odd coefficients
        R = odd(obj);

        % Evaluate the polynomial
        R = evaluate(obj, in);

    end
end