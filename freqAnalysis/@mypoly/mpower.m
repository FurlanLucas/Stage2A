function objout = mpower(objin, n)
    %% mpower
    %
    % Take the mpower of a poly class, defined as R(x) = P(x)^n. It will
    % use a sucession of convolutions.
    %
    % See also mtimes.
    
    %% Main

    % Take the input
    Q = objin.coef;
    
    % Simplest case
    if n == 0
        objout = mypoly(1);
        return
    elseif n == 1
        objout = objin;
        return

    % General case
    else
        R = conv(Q, Q); % It will do the convolution n times
        for i = 3:n
            R = conv(R, Q);
        end
    end

    objout = mypoly(R);

end