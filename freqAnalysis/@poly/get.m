function get(obj)
    %% get
    %
    % Get implementation for poly class.

    %% Main
    fprintf("\nPolynomial P(x) = ");
    
    power = obj.order;
    for i = 1:obj.order
        fprintf("%.4f * x^%d + ", obj.coef(i), power);
        power=power-1;
    end
    fprintf(" %f.\n\n", obj.coef(end));

end