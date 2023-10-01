function find_delay(dataIn, analysis, varargin)
    %% find_delay
    %
    % Find the system delay.

    %% Inputs

    % Default options
    type = 1;
    
    % Optional inputs
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("type")
                    type = varargin{arg, 2};
                    break;
            end
        end
    end

    %% Init variables
    disp("Delay indentification for temperature in the rear face");
    delay_matlabMethods(dataIn, analysis, 1);
    delay_corrFFT(dataIn, analysis, 1);

    disp("Delay indentification for temperature in the front face");
    delay_matlabMethods(dataIn, analysis, 2);
    delay_corrFFT(dataIn, analysis, 2);

end


