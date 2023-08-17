function out = evaluate(obj, in)
    %% polyeval
    %
    %   Evaluate a polynomial in each point.

    %% Main
    out = polyval(obj.coef, in);
    
end