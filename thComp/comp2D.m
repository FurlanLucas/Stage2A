function [diff, Mx, Mr] = comp2D(sysData, h, dt, Tmax, varargin)
    %% comp1D
    %
    % Compaires the 1D finite difference method with the analytical models

    %% Inputs

    % Default arguments
    type = 1;
    taylorOrder = 6;
    padeOrder = 6;
    seriesOrder = 10;
    MxMin = 4;
    MxMax = 20;
    MxStep = 2;
    MrMin = 40;
    MrMax = 60;
    MrStep = 10;

    % Optional inputs
    for i = 1:length(varargin)
        switch varargin{i}
            case 'type'
                type = varargin{i+1};  
            case 'taylorOrder'
                taylorOrder = varargin{i+1};  
            case 'padeOrder'
                padeOrder = varargin{i+1};    
            case 'seriesOrder'
                seriesOrder = varargin{i+1};   
            case 'MxMin'
                MxMin = varargin{i+1};        
            case 'MxMax'
                MxMax = varargin{i+1};        
            case 'MxStep'
                MxStep = varargin{i+1};      
            case 'MrMin'
                MrMin = varargin{i+1};        
            case 'MrMax'
                MrMax = varargin{i+1};        
            case 'MrStep'
                MrStep = varargin{i+1};           
            otherwise
                error("Option << " + varargin{i} + "is not available.");
        end

    end

    %% Main

    % Initialization
    Mx = MxMin:MxStep:MxMax;
    Mr = MrMin:MrStep:MrMax;
    a = cell(length(Mx), length(Mr));
    t = 0:dt:Tmax;
    u = ones(size(t));
    e_pade = zeros(length(Mx), length(Mr));
    e_taylor = zeros(length(Mx), length(Mr));

    % Simulation Taylor
    y_taylor = zeros(size(u'));
    [~, Fs_taylor] = model_2d_taylor(sysData, h, taylorOrder, seriesOrder);
    for i =1:taylorOrder+1
        y_taylor = y_taylor + lsim(Fs_taylor{i, type}, u, t);
    end

    % Simulation Pade
    y_pade = zeros(size(u'));
    [~, Fs_pade] = model_2d_pade(sysData, h, padeOrder, seriesOrder);
    for i =1:padeOrder+1
        y_pade = y_pade + lsim(Fs_pade{i, type}, u, t);
    end
    
    % Display
    msg1 = "\tAnalysis of Mx = 0/" + Mx(end) + " for ";
    msg2 = "Mr = 0/" + Mr(end) + "\n";
    fprintf(msg1+msg2);

    % Main loop
    for i=1:length(Mx)

        % Display
        fprintf(repmat('\b', 1, strlength(msg1+msg2)-2));
        msg1 = "\tAnalysis of Mx = " + Mx(i) + "/" + Mx(end) + " for ";
        msg2 = "Mr = 0/" + Mr(end) + "\n";
        fprintf(msg1 + msg2);

        for j = 1:length(Mr)
            % Display
            fprintf(repmat('\b', 1, strlength(msg2)-1));
            msg2 = "Mr = " + Mr(j) + "/" + Mr(end) + "\n";
            fprintf(msg2);
    
            y_findiff  = finitediff2d(sysData, t, u, h, Mx(i), ...
                Mr(j), length(t));
            a{i,j}=y_findiff{1};
            e_pade(i,j) = sum(abs(y_findiff{type} - y_pade'))/length(u);
            e_taylor(i,j) = sum(abs(y_findiff{type} - y_taylor'))/length(u);
        end      

    end

    % Output
    diff = {e_pade, e_taylor}; 
    save('a', 'a');

end