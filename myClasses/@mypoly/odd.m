function R = odd(obj)
    %% odd
    %
    % Generate a second polynomial by taking all the odd coefficients in
    % the object. If the polynomial was already odd, the result will be
    % R(x^2) = xP(x). To get the odd coefficients, since matlab index
    % starts in 1m it has to take the even values in coef attribute.

    %% Main
    pos = mod(fliplr(1:obj.order+1),2) == 0;
    R = mypoly(obj.coef(pos));
end