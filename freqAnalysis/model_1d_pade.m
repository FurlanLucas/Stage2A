function [bodeOut, Fs_pade] = model_1d_pade(sysData, h, padeOrder, varargin)
    %% model_1d_pade
    %
    % One dimentional analysis of the theorical transfer function F(s) =
    % phi(s)/theta(s), with a Pade polynomial approximation. It uses the 
    % data available in dataIn, within the field sysData.
    %
    % Calls
    %
    %   [bodeOut, Fs_pade] = model_1d_pade(dataIn, h): take the Bode diagram 
    %   for 1D model of the heat transfer using the heat transfert 
    %   coefficient h. The Pade approximation order is fixed to 10.
    %
    %   [bodeOut, Fs_pade] = model_1d_pade(dataIn, h, padeOrder): take the 
    %   Bode diagram for 1D model of the heat transfer using the heat 
    %   transfert coefficient h and an order padeOrder for the polynomial
    %   approximation.
    %
    %   [bodeOut, Fs_pade] = model_1d_pade(__, optons): take the optional 
    %   arguments.
    %
    % Inputs
    % 
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is possible also use a structure with the
    %   same fields as a sysDataType or a direct sysDataType itself;
    %
    %   h: heat transfer coefficient in W/(m²K).
    %
    % Outputs
    %   
    %   bodeOut: structure with the analysis result. It contains the field
    %   bodeOut.w with the frequences that has been used, bodeOut.mag with
    %   the magnitude and bodeOut.phase with the phases. The variables
    %   bodeOut.mag and bodeOut.phase are 1x2 cells with the values for the
    %   rear face {1} and the front face {2};
    %
    %   Fs_pade: 2x1 cell with the transfer function result from Pade
    %   approximation. The first cell corresponds to the rear face and the
    %   second to the front face.
    %
    % Aditional options
    %   
    %   wmax: minimum frequency to be used in rad/s;
    %
    %   wmax: maximum frequency to be used in rad/s;
    %
    %   wpoints: number of frequency points.
    %   
    % See also thermalData, sysDataType, model_1d.

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
    if isa(sysData, 'sysDataType')
        lambda = sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.ell;       % [m] Thermal conductivity
    elseif isa(sysData, 'thermalData')        
        lambda = sysData.sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.sysData.ell;       % [m] Thermal conductivity
    elseif isa(sysData, 'struct')
        lambda = sysData.lambda; % [W/mK] Thermal conductivity
        a = sysData.a;           % [m²/s] Thermal conductivity
        ell = sysData.ell;       % [m] Thermal conductivity
    else
        error("Input 'dataIn' is not valid.");
    end

    % Take the Pade approximation order
    if ~exist('padeOrder', 'var')
        padeOrder = 10;
    end
    
    %% Other variables for the analysis
    w = logspace(log10(wmin), log10(wmax), wpoints); % Freq. vector

    % Pade approximation
    [Q,P] = padecoef(1, padeOrder); % Aproximation e^(x) = P(xi)/Q(xi)
    P = mypoly(P); Q = mypoly(Q); % Change from vectors to mypoly variables

    %% Pade approximation for the rear model (loss included)

    % Fonction polynomials (it is not from the quadripoles)
    A_ = mypoly([lambda/(2*ell), h/2]); % Polynomial in xi
    B_ = mypoly([-lambda/(2*ell), h/2]); % Polynomial in xi

    % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
    N = P * Q; % Numerator
    D = (P*P*A_) + (Q*Q*B_); % Denominator

    % Change to the original Laplace variable s = (a/e^2)xi
    N = N.even.comp([ell^2/a 0]);
    D = D.even.comp([ell^2/a 0]);    

    % Unicity of F(s) (d0 = 1)
    N.coef = N.coef/D.coef(end); 
    D.coef = D.coef/D.coef(end);
    
    % Bode diagram for the function
    F_approx_ev = N.evaluate(w*1j)./D.evaluate(w*1j);
    mag_pade{1} = abs(F_approx_ev);
    phase_pade{1} = angle(F_approx_ev);
    Fs_pade{1} = tf(N.coef, D.coef);

    %% Pade approximation for the front model (loss included)

    % Fonction polynomials (it is not from the quadripoles)
    A_ = mypoly([1/2, h*ell/(2*lambda)]); % Polynomial in xi
    B_ = mypoly([1/2, -h*ell/(2*lambda)]); % Polynomial in xi

    % Aproximation for the transfert function F(xi) = N(xi)/D(xi)
    N = P*Q*mypoly([1,0]); % Numerator
    D = (P*P*A_) + (Q*Q*B_); % Denominator

    % Change to the original Laplace variable s = (a/e^2)xi
    N = N.odd.comp([ell^2/a 0]);
    D = D.odd.comp([ell^2/a 0]);

    % Unicity of F(s) (d0 = 1)
    N.coef = N.coef/D.coef(end); 
    D.coef = D.coef/D.coef(end);
    
    % Bode diagram for the function
    F_approx_ev = N.evaluate(w*1j)./D.evaluate(w*1j);
    mag_pade{2} = abs(F_approx_ev);
    phase_pade{2} = angle(F_approx_ev);
    Fs_pade{2} = tf(N.coef, D.coef);

    %% Results
    bodeOut.w = w;
    bodeOut.mag = mag_pade;
    bodeOut.phase = phase_pade;
    
end