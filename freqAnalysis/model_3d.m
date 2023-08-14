function bodeOut = model_3d(dataIn, h, seriesOrder, varargin)
    %% model_3d
    %
    % Three dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), without polynomial approximation. It uses the data
    % available in dataIn, within the field sysData and suppose to have a
    % cubic system.
    %
    % Calls
    %
    %   bodeOut = model_3d(dataIn, h): take the Bode diagram for 3D model
    %   of the heat transfer using the heat transfert coefficient h. The
    %   series order is taken to be 6;
    %
    %   bodeOut = model_3d(dataIn, h, seriesOrder): take the Bode diagram 
    %   for 3D model of the heat transfer using the heat transfert 
    %   coefficient h and a series in the r direction of order seriesOrder;
    %
    %   bodeOut = model_3d(__, optons): take the optional arguments.
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
    %   seriesOrder: number of terms + 1 for the series in x and y 
    %   directions.
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
        Ly = dataIn.sysData.Size;     % [m] Termocouple size
        Lz = dataIn.sysData.Size;     % [m] Termocouple size
        Ly0 = dataIn.sysData.ResSize;    % [m] Resistence size
        Lz0 = dataIn.sysData.ResSize;    % [m] Resistence size
    elseif isa(dataIn, 'struct')
        lambda = dataIn.lambda; % [W/mK] Thermal conductivity
        a = dataIn.a;           % [m²/s] Thermal conductivity
        ell = dataIn.ell;       % [m] Thermal conductivity
        Ly = dataIn.Size;     % [m] Termocouple size
        Lz = dataIn.Size;     % [m] Termocouple size
        Ly0 = dataIn.ResSize;    % [m] Resistence size
        Lz0 = dataIn.ResSize;    % [m] Resistence size
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
    lambda_y = lambda;
    lambda_z = lambda;

    % Thermal diffusivity (x)
    a_x = a;

    % Heat transfert coefficient
    hx2 = h(1); % Natural convection in x2
    hy1 = h(2); % Natural convection in y1
    hy2 = h(3); % Natural convection in y2
    hz1 = h(4); % Natural convection in z1
    hz2 = h(5); % Natural convection in z2

    % Biot numbers
    Hy1 = hy1*Ly/lambda_y; % Natural convection in y1
    Hy2 = hy2*Ly/lambda_y; % Natural convection in y2
    Hz1 = hz1*Lz/lambda_z; % Natural convection in z1
    Hz2 = hz2*Lz/lambda_z; % Natural convection in z2

    % Position to be analysed in x and y directions
    y = Ly/2;
    z = Lz/2;

    % Other parameters
    correc = 1e-8;            % [-] Numeric error factor

    %% Eigen value equation roots

    % Take the solutions for alpha_n (in the y direction)
    alpha = zeros(1, seriesOrder+1);
    f = @(alpha) cot(alpha*Ly) - ...
            ((lambda_y*alpha).^2 - hy1*hy2)./(lambda_y*alpha*(hy1+hy2));
    for i=0:seriesOrder
        alpha(i+1) = bisec(f, (i+correc)*pi/Ly, (i+1-correc)*pi/Ly);
    end
    Nalpha = (1./(2*Ly*alpha.^2)).*( Hy1 + (Hy1^2 + (alpha*Ly).^2) .* ...
        (1 + Hy2./(Hy2^2 + (alpha*Ly).^2)) );

    % Take the integral for converting to the actual tf.
    int_Y = -sin(alpha*Ly0)./alpha + (hy1./(alpha*lambda_x)) .* ...
        (cos(alpha*Ly0)./alpha - 1./alpha);
    int_Y(alpha==0) = Ly;
    
    % Take the solutions for beta_m (in the z direction)
    beta = zeros(1, seriesOrder+1);
    f = @(beta) cot(beta*Lz) - ...
            ((lambda_z*beta).^2 - hz1*hz2)./(lambda_z*beta*(hz1+hz2));
    for i=0:seriesOrder
        beta(i+1) = bisec(f, (i+correc)*pi/Lz, (i+1-correc)*pi/Lz);
    end
    Mbeta = (1./(2*Lz*beta.^2)).*( Hz1 + (Hz1^2 + (beta*Lz).^2) .* ...
        (1 + Hz2./(Hz2^2 + (beta*Lz).^2)) );

    % Take the integral for converting to the actual tf.
    int_Z = -sin(beta*Lz0)./beta + (hz1./(beta*lambda_z)) .* ...
        (cos(beta*Lz0)./beta - 1./beta);
    int_Z(beta==0) = Lz;

    %% Taylor approximation for the 3D rear face model 

    Fs_3D = {zeros(size(w)), zeros(size(w))};

    for n = 0:seriesOrder % Series in y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:seriesOrder % Series in z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);
    
            % 1D solution
            gamma = sqrt(1j*w/a_x + alpha(n+1)^2 + beta(m+1)^2);
            C = lambda_x*gamma.*sinh(ell*gamma);
            B = (1./(lambda*gamma)) .* sinh(ell*gamma);
            A = cosh(ell*gamma); % A = D

            % Rear face
            Fs_eval = 1./(C + A*hx2);
            Fs_3D{1} = Fs_3D{1} + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);
    
            % Front face
            Fs_eval = (A + B*hx2)./(C + A*hx2);
            Fs_3D{2} = Fs_3D{2} + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);
        end
    end


    %% Results
    bodeOut.w = w;
    bodeOut.mag{1} = abs(Fs_3D{1});
    bodeOut.mag{2} = abs(Fs_3D{2});
    bodeOut.phase{1} = angle(Fs_3D{1});
    bodeOut.phase{2} = angle(Fs_3D{2});
    
end
