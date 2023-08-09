function get(obj)
    %% get
    %
    % Implémentation de la fonction get pour la classe poly.

    %% Main
    fprintf("\nPolinôme P(x) = ");
    
    power = obj.order;
    for i = 1:obj.order
        fprintf("%.4f * x^%d + ", obj.coef(i), power);
        power=power-1;
    end
    fprintf(" %f.\n", obj.coef(end));

end