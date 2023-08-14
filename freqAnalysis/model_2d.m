function bodeOut = model_2d(dataIn, h, seriesOrder, varargin)
    %% model_2d
    %
    % Two dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), without polynomial approximation. It uses the data
    % available in dataIn, within the field sysData and suppose to have a
    % system axisymetric.
    %
    % Calls
    %
    %   bodeOut = model_2d(dataIn, h): take the Bode diagram for 2D model
    %   of the heat transfer using the heat transfert coefficient h. The
    %   series order is taken to be 6;
    %
    %   bodeOut = model_2d(dataIn, h, seriesOrder): take the Bode diagram 
    %   for 2D model of the heat transfer using the heat transfert 
    %   coefficient h and a series in the r direction of order seriesOrder;
    %
    %   bodeOut = model_2d(__, optons): take the optional arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is possible also use a structure with the
    %   same fields as a sysDataType;
    %
    %   h: heat transfer coefficient in W/(m²K);
    %
    %   seriesOrder: number of terms + 1 for the series in r direction.
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
        Rmax = dataIn.sysData.Size;     % [m] Termocouple size
        R0 = dataIn.sysData.ResSize;    % [m] Resistence size
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Thermal conductivity
        a = dataIn.a;           % [m²/s] Thermal conductivity
        ell = dataIn.ell;       % [m] Thermal conductivity
        Rmax = dataIn.Size;     % [m] Termocouple size
        R0 = dataIn.ResSize;    % [m] Resistence size
    else
        error("Input << dataIn >> is not valid.");
    end

    % Take the series order
    if ~exist('seriesOrder', 'var')
        seriesOrder = 6;
    end
    
    %% Other variables for the analysis
    w = logspace(log10(wmin), log10(wmax), wpoints); % Freq. vector

    % Thermal conductivity
    lambda_x = lambda;
    lambda_r = lambda;

    % Thermal diffusivity (x)
    a_x = a;

    % Position to be analysed in r direction
    r = 0;

    % Heat transfert coefficient
    hx2 = h(1); % Natural convection in x2
    hr2 = h(1); % Natural convection in r2

    %% Eigen value equation roots

    % Take the solution in the r direction
    load("J_roots.mat", 'J0', 'J1');
    
    f = @(alpha_n) hr2*besselj(0,alpha_n*Rmax) - ...
        lambda_r*besselj(1,alpha_n*Rmax).*alpha_n;
    
    alpha = zeros(seriesOrder+mod(seriesOrder,2)+1, 1);
    
    alpha(1) = bissec(f, 0, J0(1)/Rmax);
    alpha(2) = bissec(f, J1(1)/Rmax, J0(2)/Rmax);
    for i = 3:2:seriesOrder+mod(seriesOrder,2)+1
       alpha(i) = bissec(f, J1(i-1)/Rmax, J0(i)/Rmax);
       alpha(i+1) = bissec(f, J1(i)/Rmax, J0(i+1)/Rmax);
    end
    alpha = alpha(1:seriesOrder+1);
    Nalpha = ((Rmax^2) / 2) * (besselj(0, alpha*Rmax) .^ 2);

    %% Theorical model in 2D
    Fs_2D = {zeros(size(w)), zeros(size(w))};

    for n = 0:seriesOrder % Serie in r
        R = besselj(0, alpha(n+1)*r);

        % Take the integral for converting to the actual tf.
        int_R = (R0/alpha(n+1)) * besselj(1, alpha(n+1)*R0);
    
        % Quadripole resolution
        gamma = sqrt(1j*w/a_x + alpha(n+1)^2);
        C = lambda_x*gamma.*sinh(ell*gamma);
        B = (1./(lambda*gamma)) .* sinh(ell*gamma);
        A = cosh(ell*gamma); % D = A

        % Rear face
        Fs_eval = 1./(C + A*hx2);
        Fs_2D{1} = Fs_2D{1} + Fs_eval * (R/Nalpha(n+1))*int_R;

        % Front face
        Fs_eval = (A + B*hx2)./(C + A*hx2);
        Fs_2D{2} = Fs_2D{2} + Fs_eval * (R/Nalpha(n+1))*int_R;

    end

    %% Result
    bodeOut.w = w;
    bodeOut.mag{1} = abs(Fs_2D{1});
    bodeOut.mag{2} = abs(Fs_2D{2});
    bodeOut.phase{1} = angle(Fs_2D{1});
    bodeOut.phase{2} = angle(Fs_2D{2});
    
end
