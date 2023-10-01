function objOut = add(obj, t, v, y_back, y_front)
    %% add
    %
    % Method to add a new experimental data to the dataset.
    %
    % See also thermalData.

    %% Main 
    obj.Ne = obj.Ne+1;
    obj.y_back{obj.Ne} = y_back;
    obj.y_front{obj.Ne} = y_front;
    obj.t{obj.Ne} = t;
    obj.v{obj.Ne} = v;

    % Output
    objOut = obj;
    
end