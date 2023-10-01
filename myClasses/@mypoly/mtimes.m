function objout = mtimes(objin1, objin2)
    %% mtimes
    %
    % Implementation of multiplication for poly class, defined as R(x) =
    % P(x) * Q(x). Will use the convolution to do it.

    %% Main
    objout = mypoly(conv(objin1.coef, objin2.coef));

end