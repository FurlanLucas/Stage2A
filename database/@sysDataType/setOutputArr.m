function y = setOutputArr(obj, in)
    %% setOutputArr
    %
    % Configure la sortie en variation de température dans la face arrière
    % en utilisant le coeficient Y_tr du termocouple. Il est nécessaire
    % avoir une proprieté Y_tr non nulle.

    %% Main
    if obj.Ytr_arr ~= 0
        y = in/(obj.Ytr_arr*1e-6);
    else
        error("Le champs 'Ytr_arr' pour le coefficient du " + ...
            "thermocouple n'a pas été specifié.");
    end
end