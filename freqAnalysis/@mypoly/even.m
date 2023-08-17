function R = even(obj)
    %% even
    %
    % Generate a second polynomial by taking all the even coefficients in
    % the object. If the polynomial was already even, the result will be
    % R(x^2) = P(x).

    %% Main
    pos = mod(fliplr(1:obj.order+1),2) == 0;
    R = mypoly(obj.coef(pos));
end