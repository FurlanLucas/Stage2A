function y = setOutputBack(obj, in)
    %% setOutputBack
    %
    % Change the output from volts to °C (or K) variation in the rear face,
    % defined as (x=ell).
    %
    % See also sysDataType.

    %% Main
    if obj.Ytr_back ~= 0
        y = in/(obj.Ytr_back*1e-6);
    else
        error("The thermocouple coefficient value was not defined.");
    end
end