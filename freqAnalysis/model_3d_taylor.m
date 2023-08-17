function [bodeOut, Fs_taylor] = model_3d_taylor(dataIn, h, taylorOrder, ...
    seriesOrder, varargin)
    %% model_3d_taylor
    %
    % Three dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), with Taylor polynomial approximation. It uses the data
    % available in dataIn, within the field sysData and suppose to have a
    % system axisymetric.
    %
    % Calls
    %
    %   [bodeOut, Fs_taylor] = model_3d_taylor(dataIn, h): take the Bode 
    %   diagram for 3D model of the heat transfer using the heat transfert 
    %   coefficient h. The series order is fixed to be 6 and the polynomial 
    %   approximation order to be 10;
    %
    %   [bodeOut, Fs_taylor] = model_3d_taylor(dataIn, h, seriesOrder): take 
    %   the Bode diagram for 3D model of the heat transfer using the heat 
    %   transfert coefficient h and a series in the r direction of order 
    %   seriesOrder. The polynomial approximation order is fixed to be 10;
    %
    %   [bodeOut, Fs_taylor] = model_3d_taylor(dataIn, h, seriesOrder, 
    %   taylorOrder): take the Bode diagram for 3D model of the heat transfer 
    %   using the heat transfert coefficient h and a series in the x and
    %   y directions of order seriesOrder. The polynomial approximation order 
    %   is taken as taylorOrder;
    %
    %   [bodeOut, Fs_taylor] = model_3d_taylor(__, optons): take the optional 
    %   arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is possible also use a structure with the
    %   same fields as a sysDataType;
    %
    %   h: vector of heat transfer coefficients in W/(m²K). The first one
    %   is the value for the rear face hx2 and the second and third one are
    %   relative to the y direction (hy1 and hy2). The last two values are
    %   for the z direction (hz1 and hz2);
    %
    %   seriesOrder: number of terms + 1 for the series in x and y
    %   directions;
    %   
    %   taylorOrder: define the order of the polynomial approximation.
    %
    % Outputs
    %   
    %   bodeOut: structure with the analysis result. It contains the field
    %   bodeOut.w with the frequences that has been used, bodeOut.mag with
    %   the magnitude and bodeOut.phase with the phases. The variables
    %   bodeOut.mag and bodeOut.phase are 1x2 cells with the values for the
    %   rear face {1} and the front face {2};
    %
    %   Fs_taylor: Mx2 cell with the transfer function result from Taylor
    %   approximation. The first column corresponds to the rear face and 
    %   the one to the front face. Each row is one term resultant from the
    %   serie analysis.
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

    % Aproximation e^(x) = P(xi)/Q(xi)
    n = taylorOrder:-1:0;
    P = mypoly((1/2).^n ./ factorial(n)); % Change from vectors to poly variables
    Q = mypoly((-1/2).^n ./ factorial(n)); % Change from vectors to poly variables

    % Sorties (initialization)
    Fs_taylor_ev = {zeros(size(w)), zeros(size(w))}; % Vector with the solutions
    Fs_taylor = cell(seriesOrder+1, 2); % Transfert function

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
    int_Y = zeros(size(alpha)); int_Y(1) = Lz0;
    int_Y(2:end) = -sin(alpha(2:end)*Ly0)./alpha(2:end) + ...
                    (hy1./(alpha(2:end)*lambda_x)) .* ...
                    (cos(alpha(2:end)*Ly0)./alpha(2:end) - 1./alpha(2:end));
    
    %Take the solutions for beta_m (in the z direction)
    beta = zeros(1, seriesOrder+1);
    f = @(beta) cot(beta*Lz) - ...
            ((lambda_z*beta).^2 - hz1*hz2)./(lambda_z*beta*(hz1+hz2));
    for i=0:seriesOrder
        beta(i+1) = bisec(f, (i+correc)*pi/Lz, (i+1-correc)*pi/Lz);
    end

    Mbeta = (1./(2*Lz*beta.^2)).*( Hz1 + (Hz1^2 + (beta*Lz).^2) .* ...
        (1 + Hz2./(Hz2^2 + (beta*Lz).^2)) );

    % Take the integral for converting to the actual tf.
    int_Z = zeros(size(beta)); int_Z(1) = Lz0;
    int_Z(2:end) = -sin(beta(2:end)*Lz0)./beta(2:end) + ...
                    (hz1./(beta(2:end)*lambda_z)) .* ...
                    (cos(beta(2:end)*Lz0)./beta(2:end) - 1./beta(2:end));

    %% Taylor approximation for the 3D rear face model 

    % Fonction polynomials (it is not from the quadripoles)   
    A_ = mypoly([lambda_x/(2*ell), hx2/2]); % Polynomial in xi
    B_ = mypoly([-lambda_x/(2*ell), hx2/2]); % Polynomial in xi

    for n = 0:seriesOrder % Serie en y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:seriesOrder % Serie en z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);

            % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
            N = P * Q; % Numerator
            D = (P*P*A_) + (Q*Q*B_); % Denominator
        
            % Change to the original Laplace variable s = (a/e^2)xi
            N = N.odd.comp([ell^2/a_x, (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);
            D = D.odd.comp([ell^2/a_x, (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);    
        
        
            % Unicity of F(s) (d0 = 1)
            N.coef = N.coef/D.coef(end); 
            D.coef = D.coef/D.coef(end);
        
            % Bode diagram
            Fs_eval = N.evaluate(w*1j)./D.evaluate(w*1j);       
    
            % Add the result transfer functions
            Fs_taylor_ev{1} = Fs_taylor_ev{1} + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);
            
            % Transfer function
            Fs_taylor{n+1, 1} = tf(N.coef,D.coef) * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);

        end
    end

    %% Taylor approximation for the 3D front face model 

    % Fonction polynomials (it is not from the quadripoles)  
    A_ = mypoly([lambda_x/ell, hx2]); % Polynomial in xi
    B_ = mypoly([lambda_x/ell, -hx2]); % Polynomial in xi
    C_ = mypoly([(lambda_x/ell)^2, hx2*lambda_x/ell 0]); % Polynomial in xi
    D_ = mypoly([-(lambda_x/ell)^2, hx2*lambda_x/ell 0]); % Polynomial in xi

    for n = 0:seriesOrder % Serie en y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:seriesOrder % Serie en z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);

            % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
            N = (P*P*A_) + (Q*Q*B_); % Numerator
            D = (P*P*C_) + (Q*Q*D_); % Denominator
        
            % Change to the original Laplace variable s = (a/e^2)xi
            N = N.even.comp([ell^2/a_x, (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);
            D = D.even.comp([ell^2/a_x, (alpha(n+1)*ell)^2 + (beta(m+1)*ell)^2]);    
        
            % Unicity of F(s) (d0 = 1)
            N.coef = N.coef/D.coef(end); 
            D.coef = D.coef/D.coef(end);
        
            % Bode diagram
            Fs_eval = N.evaluate(w*1j)./D.evaluate(w*1j);       
    
            % Add the result transfer functions
            Fs_taylor_ev{2} = Fs_taylor_ev{2} + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);
            
            % Transfer function
            Fs_taylor{n+1, 2} = tf(N.coef,D.coef) * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z(m+1)*int_Y(n+1);

        end
    end

    %% Results
    bodeOut.w = w;
    bodeOut.mag{1} = abs(Fs_taylor_ev{1});
    bodeOut.mag{2} = abs(Fs_taylor_ev{2});
    bodeOut.phase{1} = angle(Fs_taylor_ev{1});
    bodeOut.phase{2} = angle(Fs_taylor_ev{2});       

    
end
