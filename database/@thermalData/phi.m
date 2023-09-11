function phi = phi(obj)
    %% phiV
    %
    %   Work as a atributte, giving the same output as obj.phi, but
    %   calculated with the tension in the resistence.

    %% Main

    phi = cell(size(obj.v));
    for i = 1:length(obj.v)
        phi{i} = obj.v{i}.^2 * ...
            (obj.sysData.R/((obj.sysData.R_ + obj.sysData.R)^2)) ...
            /obj.sysData.takeResArea;
    end

end