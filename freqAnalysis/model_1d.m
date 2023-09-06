function bodeOut = model_1d(dataIn, h, varargin)
    %% model_1d
    %
    % One dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), without polynomial approximation. It uses the data
    % available in dataIn, within the field sysData.
    %
    % Calls
    %
    %   bodeOut = model_1d(dataIn, h): take the Bode diagram for 1D model
    %   of the heat transfer using the heat transfert coefficient h;
    %
    %   bodeOut = model_1d(__, optons): take the optional arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is possible also use a structure with the
    %   same fields as a sysDataType;
    %
    %   h: heat transfer coefficient in W/(m²K).
    %
    % Outputs
    %   
    %   bodeOut: structure with the analysis result. It contains the field
    %   bodeOut.w with the frequences that has been used, bodeOut.mag with
    %   the magnitude and bodeOut.phase with the phases. The variables
    %   bodeOut.mag and bodeOut.phase are 1x2 cells with the values for the
    %   rear face {1} and the front face {2}.
    %
    % Aditional options
    %   
    %   wmax: minimum frequency to be used in rad/s;
    %
    %   wmax: maximum frequency to be used in rad/s;
    %
    %   wpoints: number of frequency points.
    %   
    % See also thermalData, sysDataType.

    %% Inputs and constants

    wmin = 1e-3;              % [rad/s] Minimum frequency
    wmax = 1e2;               % [rad/s] Maximum frequency
    wpoints = 1000;           % [rad/s] Number of frequency points  

    %% Aditional options

    % Verify the optional arguments
    for i=1:2:length(varargin)        
        switch varargin{i}
            % Minimum frequency
            case 'wmin'
                wmin = varargin{i+1};

            % Maximum frequency
            case 'wmax'      
                wmax = varargin{i+1};

            % Number of frequency points 
            case 'wpoints'     
                wpoints = varargin{i+1};

            % Error
            otherwise
                error("Option << " + varargin{i} + "is not available.");
        end
    end

    % Verify the input type
    if isa(dataIn, 'thermalData')
        lambda = dataIn.sysData.lambda; % [W/mK] Thermal conductivity
        a = dataIn.sysData.a;           % [m²/s] Thermal conductivity
        ell = dataIn.sysData.ell;       % [m] Thermal conductivity
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Thermal conductivity
        a = dataIn.a;           % [m²/s] Thermal conductivity
        ell = dataIn.ell;       % [m] Thermal conductivity
    else
        error("Input << dataIn >> is not valid.");
    end

    %% Other variables
    w = logspace(log10(wmin), log10(wmax), wpoints); % Frequency vector

    %% Theorical model in 1D
    
    % Equation solution in 1D
    k = sqrt(w*1j/a); 
    C = lambda*k.*sinh(ell*k);
    B = (1./(lambda*k)) .* sinh(ell*k);
    A = cosh(ell*k); % D = A
    
    % Rear face
    Fs_th = 1./(C + A*h);
    mag_th{1} = abs(Fs_th);
    phase_th{1} = angle(Fs_th);

    % Front face
    Fs_th = 1./(A + B*h);
    mag_th{2} = abs(Fs_th);
    phase_th{2} = angle(Fs_th);

    %% Results
    bodeOut.w = w;
    bodeOut.mag = mag_th;
    bodeOut.phase = phase_th;    
    
end