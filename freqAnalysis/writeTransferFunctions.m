function writeTransferFunctions(expData, analysis, h, varargin)
    %% writeTransferFunctions
    %
    % Write transfer functions to tex files, using a factor power in the
    % numerator.
    %
    % See also Contents.

    %% Inputs

    % Default values
    order = 6;      % Order for polynomial approximations
    Ts = 100e-3;    % [ms] Sampling time for discretization

    %% Main

    % Taylor 1D
    [~, Fs_taylor_1d] = model_1d_taylor(expData, h, order);
    tf2tex(Fs_taylor_1d{1}, analysis, "\\widetilde{G}_\\varphi", ...
        'G_1d_taylor_cont', 5);
    tf2tex(c2d(Fs_taylor_1d{1}, Ts, 'zoh'), analysis, ...
        "\\widetilde{G}_\\varphi", 'G_1d_taylor_disc', 5);
    
    % Pade 1D
    [~, Fs_pade_1d] = model_1d_pade(expData, h, order);
    tf2tex(Fs_pade_1d{1}, analysis, "\\widetilde{G}_\\varphi", ...
        'G_1d_pade_cont', 5);
    tf2tex(c2d(Fs_pade_1d{1}, Ts, 'zoh'), analysis, ...
        "\\widetilde{G}_\\varphi", 'G_1d_pade_disc', 5);

end