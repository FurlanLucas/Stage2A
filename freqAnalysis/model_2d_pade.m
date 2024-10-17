function [bodeOut, Fs_pade] = model_2d_pade(sysData, h, padeOrder, ...
    seriesOrder, varargin)
    %% model_2d_pade
    %
    % Two dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), with Pade polynomial approximation. It uses the data
    % available in dataIn, within the field sysData and suppose to have a
    % system axisymetric.
    %
    % Calls
    %
    %   [bodeOut, Fs_pade] = model_2d_pade(dataIn, h): take the Bode diagram 
    %   for 2D model of the heat transfer using the heat transfert 
    %   coefficient h. The series order is fixed to be 6 and the polynomial 
    %   approximation order to be 10;
    %
    %   [bodeOut, Fs_pade] = model_2d_pade(dataIn, h, seriesOrder): take 
    %   the Bode diagram for 2D model of the heat transfer using the heat 
    %   transfert coefficient h and a series in the r direction of order 
    %   seriesOrder. The polynomial approximation order is fixed to be 10;
    %
    %   [bodeOut, Fs_pade] = model_2d_pade(dataIn, h, seriesOrder, 
    %   padeOrder): take the Bode diagram for 2D model of the heat transfer 
    %   using the heat transfert coefficient h and a series in the r direction 
    %   of order seriesOrder. The polynomial approximation order is taken as 
    %   padeOrder;
    %
    %   [bodeOut, Fs_pade] = model_2d_pade(__, optons): take the optional 
    %   arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is possible also use a structure with the
    %   same fields as a sysDataType or a direct sysDataType itself;
    %
    %   h: vector of heat transfer coefficients in W/(m²K). The first one
    %   is the value for the rear face hx2 and the second one is to the
    %   external surface in r direction hr2;
    %
    %   seriesOrder: number of terms + 1 for the series in r direction;
    %   
    %   padeOrder: define the order of the polynomial approximation.
    %
    % Outputs
    %   
    %   bodeOut: structure with the analysis result. It contains the field
    %   bodeOut.w with the frequences that has been used, bodeOut.mag with
    %   the magnitude and bodeOut.phase with the phases. The variables
    %   bodeOut.mag and bodeOut.phase are 1x2 cells with the values for the
    %   rear face {1} and the front face {2};
    %
    %   Fs_pade: Mx2 cell with the transfer function result from Pade
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
            case 'wmin' % Minimum frequency
                wmin = varargin{i+1};            
            case 'wmax' % Maximum frequency    
                wmax = varargin{i+1};            
            case 'wpoints' % Number of frequency points      
                wpoints = varargin{i+1}; 
            otherwise
                error("Option '" + varargin{i} + "' is not available.");
        end
    end

    % Verify the input type
    if isa(sysData, 'thermalData')
        lambda = sysData.sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.sysData.ell;       % [m] Thermal conductivity
        Rmax = sysData.sysData.Size;     % [m] Termocouple size
        R0 = sysData.sysData.ResSize;    % [m] Resistence size
    elseif isa(sysData, 'sysDataType')
        lambda = sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.ell;       % [m] Thermal conductivity
        Rmax = sysData.Size;     % [m] Termocouple size
        R0 = sysData.ResSize;    % [m] Resistence size
    elseif isa(sysData, 'struct')
        lambda = sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.ell;       % [m] Thermal conductivity
        Rmax = sysData.Size;     % [m] Termocouple size
        R0 = sysData.ResSize;    % [m] Resistence size
    else
        error("Input 'dataIn' is not valid.");
    end

    % Take the series order
    if ~exist('seriesOrder', 'var')
        seriesOrder = 6;
    end

    % Take Pade order approximation
    if ~exist('padeOrder', 'var')
        padeOrder = 10;
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

    % Aproximation e^(x) = P(xi)/Q(xi)
    [Q,P] = padecoef(1, padeOrder);
    P = mypoly(P); Q = mypoly(Q); % Change from vectors to poly variables

    % Outputs(initialization)
    Fs_pade_ev = {zeros(size(w)), zeros(size(w))}; % Vector with the solutions
    Fs_pade = cell(seriesOrder+1, 2); % Transfert function

    %% Eigen value equation roots

    % Take the solution in the r direction
    load("J_roots.mat", 'J0', 'J1');
    
    f = @(alpha_n) hr2*besselj(0,alpha_n*Rmax) - ...
        lambda_r*besselj(1,alpha_n*Rmax).*alpha_n;
    
    alpha = zeros(seriesOrder+1, 1);
    
    alpha(1) = bisec(f, 0, J0(1)/Rmax);
    for i = 1:seriesOrder
       alpha(i+1) = bisec(f, J1(i)/Rmax, J0(i+1)/Rmax);
    end

    Malpha = (besselj(0, alpha*Rmax) .^ 2).*((Rmax * alpha).^2 + ...
        (Rmax * hr2 / lambda_r)^2)./(2*(alpha.^2)); 

    % Take the integral for converting to the actual tf.
    int_R = (R0./alpha) .* besselj(1, alpha*R0);
    % int_R2 = Rmax*(hr2./(lambda*alpha.^2)) besselj(0, alpha*Rmax)

    tt = 2*(Rmax/R0/R0)*(besselj(0, alpha*Rmax)./(besselj(0, alpha*R0).^2)) ./ ...
        (lambda_r*(alpha.^2)/hr2 + hr2/lambda_r)

    %% Pade approximation for the 2D rear face model 

    % Fonction polynomials (it is not from the quadripoles)   
    A_ = mypoly([lambda_x/(2*ell), hx2/2]); % Polynomial in xi
    B_ = mypoly([-lambda_x/(2*ell), hx2/2]); % Polynomial in xi

    for n = 0:seriesOrder % Serie in r
        R = besselj(0, r*alpha(n+1));

        % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
        N = P * Q; % Numerator
        D = (P*P*A_) + (Q*Q*B_); % Denominator
    
        % Change to the original Laplace variable s = (a/e^2)xi
        N = N.even.comp([ell^2/a_x (alpha(n+1)*ell)^2]);
        D = D.even.comp([ell^2/a_x (alpha(n+1)*ell)^2]);    
    
        % Unicity of F(s) (d0 = 1)
        N.coef = N.coef/D.coef(end); 
        D.coef = D.coef/D.coef(end);

        % Bode diagram
        Fs_eval = N.evaluate(w*1j)./D.evaluate(w*1j);       

        % Add the result transfer functions
        Fs_pade_ev{1} = Fs_pade_ev{1} + Fs_eval * (R/Malpha(n+1))*int_R(n+1);
        
        % Transfer function
        Fs_pade{n+1, 1} = tf(N.coef,D.coef) * (R/Malpha(n+1))*int_R(n+1);
    end

    %% Pade approximation for the 2D front face model 
    
    % Fonction polynomials (it is not from the quadripoles)
    A_ = mypoly([1/2, hx2*ell/(2*lambda_x)]); % Polynomial in xi
    B_ = mypoly([1/2, -hx2*ell/(2*lambda_x)]); % Polynomial in xi

    for n = 0:seriesOrder % Serie en r
        R = besselj(0, r*alpha(n+1));

        % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
        N = P*Q*mypoly([1,0]); % Numerator
        D = (P*P*A_) + (Q*Q*B_); % Denominator
    
        % Change to the original Laplace variable s = (a/e^2)xi
        N = N.odd.comp([ell^2/a_x (alpha(n+1)*ell)^2]);
        D = D.odd.comp([ell^2/a_x (alpha(n+1)*ell)^2]);    
    
        % Unicity of F(s) (d0 = 1)
        N.coef = N.coef/D.coef(end); 
        D.coef = D.coef/D.coef(end);

        % Bode diagram
        Fs_eval = N.evaluate(w*1j)./D.evaluate(w*1j);

        % % Add the result transfer functions
        Fs_pade_ev{2} = Fs_pade_ev{2} + Fs_eval * (R/Malpha(n+1))*int_R(n+1);
        
        % Transfer function
        Fs_pade{n+1, 2} = tf(N.coef,D.coef) * (R/Malpha(n+1))*int_R(n+1);
    end

    %% Results
    bodeOut.w = w;
    bodeOut.mag{1} = abs(Fs_pade_ev{1});
    bodeOut.mag{2} = abs(Fs_pade_ev{2});
    bodeOut.phase{1} = angle(Fs_pade_ev{1});
    bodeOut.phase{2} = angle(Fs_pade_ev{2});       

end
