function phi = toFlux(obj, v)
    %% toFLux
    %
    % Change the output tension measured in (volts) the heat flux sensor
    % to actually heat flux (W/m²), using the sensor coefficient.
    %
    % See also sysDataType.

    %% Main
    phi = (v/(obj.R+obj.R_)).^2 * obj.R / obj.takeResArea;

end