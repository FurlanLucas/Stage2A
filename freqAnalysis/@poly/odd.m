function R = odd(obj)
    %% odd
    %
    % Generate a second polynomial by taking all the odd coefficients in
    % the object. If the polynomial was already odd, the result will be
    % R(x^2) = xP(x).
    %% Main
    pos = mod(fliplr(1:obj.order+1),2) == 1;
    R = poly(obj.coef(pos));
end