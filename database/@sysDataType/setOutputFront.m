function y = setOutputFront(obj, in)
    %% setOutputArr
    %
    % Configure la sortie en variation de température dans la face avant
    % en utilisant le coeficient Y_tr du termocouple. Il est nécessaire
    % avoir une proprieté Y_tr non nulle.

    %% Main
    if obj.Ytr_front ~= 0
        y = in/(obj.Ytr_front*1e-6);
    else
        error("Le champs 'Ytr_avant' pour le coefficient du " + ...
            "thermocouple n'a pas été specifié.");
    end
end