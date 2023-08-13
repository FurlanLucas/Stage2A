function objout = plus(objin1, objin2)
    %% plus
    %
    % Take the sum of two polynomials. Its necessary to shift the smallest
    % polynomial to add the coefficients all together.

    %% Main
    P = objin1.coef;
    Q = objin2.coef;
    
    % Take the biggest
    P_order = length(P);
    Q_order = length(Q);
    if P_order > Q_order
         max_order = size(P);
    else
         max_order = size(Q);
    end

    % Ajustment
    new_P = padarray(P, max_order-size(P), 0, 'pre');
    new_Q = padarray(Q, max_order-size(Q), 0, 'pre');
    R = new_P + new_Q;

    % Output
    objout = poly(R);

end