function R = changeVariable(Q, P)
    % IL va changer la variable du polinôme Q(y) pour y = P(x) et retourner
    % un nouvel polynôme R(x) = Q(P(x)). Des convolution sucessives sont
    % utilisées.
    % R(x) = sum( r_i * x^i ) ;
    %      = sum( q_i * (p(x))^i ) ;

    R = 0;
    for i=0:length(Q)-1
        R = sumPoly(R, Q(length(Q)-i)*polyPower(P, i));
    end
end