function y = setOutputFront(obj, in)
    %% setOutputFront
    %
    % Change the output from volts to °C (or K) variation in the front face,
    % defined as (x=0).
    %
    % See also sysDataType.

    %% Main
    if obj.Ytr_front ~= 0
        y = in/(obj.Ytr_front*1e-6);
    else
        error("The thermocouple coefficient value was not defined.");
    end
end