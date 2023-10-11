function [diff, time, Mx] = comp1D(sysData, h, dt, Tmax, varargin)
    %% comp1D
    %
    % Compaires the 1D finite difference method with the analytical models

    %% Inputs

    % Default arguments
    type = 1;
    taylorOrder = 6;
    padeOrder = 6;
    MxMin = 4;
    MxMax = 20;
    MxStep = 2;

    % Optional inputs
    for i = 1:length(varargin)
        switch varargin{i}
            case 'type'
                type = varargin{i+1};  
            case 'taylorOrder'
                taylorOrder = varargin{i+1};  
            case 'padeOrder'
                padeOrder = varargin{i+1};        
            case 'MxMin'
                MxMin = varargin{i+1};        
            case 'MxMax'
                MxMax = varargin{i+1};        
            case 'MxStep'
                MxStep = varargin{i+1};          
            otherwise
                error("Option << " + varargin{i} + "is not available.");
        end

    end

    %% Main

    % Initialization
    Mx = MxMin:MxStep:MxMax;
    t = 0:dt:Tmax;
    u = ones(size(t));
    e_pade = zeros(size(Mx));
    e_taylor = zeros(size(Mx));
    time_diff = zeros(size(Mx));

    % Simulation Taylor
    tic;
    [~, Fs_taylor] = model_1d_taylor(sysData, h, taylorOrder);
    time_taylor = toc;
    y_taylor = lsim(Fs_taylor{type}, u, t);

    % Simulation Pade
    tic;
    [~, Fs_pade] = model_1d_taylor(sysData, h, padeOrder);
    time_pade = toc;
    y_pade = lsim(Fs_pade{type}, u, t);
    
    % Display
    msg = "\tAnalysis of Mx = 0/" + Mx(end) + "\n";
    fprintf(msg);

    % Main loop
    for i=1:length(Mx)
        fprintf(repmat('\b', 1, strlength(msg)-2));
        msg = "\tAnalysis of Mx = " + Mx(i) + "/" + Mx(end) + "\n";
        fprintf(msg);

        tic;
        y_findiff  = finitediff1d(sysData, t, u, h, Mx(i), length(t));
        time_diff(i) = toc;
        e_pade(i) = sum(abs(y_findiff{type} - y_pade'))/length(u);
        e_taylor(i) = sum(abs(y_findiff{type} - y_taylor'))/length(u);
    end

    % Output
    fprintf(repmat('\b', 1, strlength(msg)-2));
    diff = {e_pade, e_taylor}; 
    time = {time_pade, time_taylor, time_diff};

end