function objout = plus(objin1, objin2)
    %% plus
    %
    % Prendre la summe de deux polynômes P(x) et Q(x). Il faut aligner les
    % deux vecteur de coefficientes dans un façon que il sera possibles de
    % les ajouter.

    %% Main
    P = objin1.coef;
    Q = objin2.coef;
    
    % Prendre l'ordre plus grande
    P_order = length(P);
    Q_order = length(Q);
    if P_order > Q_order
         max_order = size(P);
    else
         max_order = size(Q);
    end

    % Ajoute les deux polynômes
    new_P = padarray(P, max_order-size(P), 0, 'pre');
    new_Q = padarray(Q, max_order-size(Q), 0, 'pre');
    R = new_P + new_Q;

    % Sortie
    objout = poly(R);

end