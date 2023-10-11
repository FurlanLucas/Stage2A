function [phi, t_out, Gm_inv] = minPhaseBack(dataIn, analysis, model, varargin)
    %% minPhaseBack
    %
    % Function to invert the model and validate it with reentry data. The
    % input will be tha last experiment available in dataIn as a reentry
    % data. The inversion is done by minimum phase approximation.
    %
    % Calls
    %
    %   [phi, t_out, Gm_inv] = minPhaseBack(dataIn, analysis, model):
    %   estimate the heat flux phi during the time t_out by using the
    %   minimum phase approximation. It also returns the inverse transfer
    %   function G_inv;
    %
    %   [phi, t_out, Gm_inv] = minPhaseBack(__, options): take the optional 
    %   arguments.
    %
    % Inputs
    %
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated. The thermal coefficients are within
    %   the field sysData. It is not possible also use a structure in this
    %   case;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   model: model to be inverted (will be a back model, with respect to
    %   the heat flux in front face).
    %
    % Outputs
    %
    %   phi: vector of estimated heat flux;
    %
    %   t_out: output time ;
    %
    %   G_inv: inverse system's transfer function.
    %
    % Aditional options
    %   
    %   wmax: minimum frequency to be used in rad/s;
    %
    %   wmax: maximum frequency to be used in rad/s;
    %
    %   wpoints: number of frequency points.
    %
    % See convergence, iddata, sysDataType, thermalData.

    %% Inputs
    figDir = analysis.figDir;   % Directory for output figures
    analysisName = dataIn.Name; % Analysis name 

    % Default values
    wmin = 1e-3;              % [rad/s] Minimum frequency
    wmax = 1e-1;               % [rad/s] Maximum frequency
    wpoints = 1000;           % [rad/s] Number of frequency points 

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

    w = logspace(log10(wmin), log10(wmax), wpoints); % Frequency vector
    validPos = dataIn.isPRBS(end);
    reentryPos = dataIn.isReentry(end);

    %% Direct system's model

    G = tf(model.B, model.A, model.Ts);
    G.TimeUnit = model.TimeUnit;
    fig = figure; pzplot(G);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_pzplot_before.eps", 'epsc');  
    
    % Take 'unstable' zeros
    out_zeros = zpk(model).Z{1};
    out_zeros = out_zeros(abs(out_zeros)>=1);
    
    % All pass filter
    Pt = zpk(out_zeros, 1./conj(out_zeros), 1/real(prod(-out_zeros)),...
        model.Ts);
    Pt.TimeUnit = model.TimeUnit;

    % Approximation by minimum phase
    Gm = minreal(G/Pt);
    Gm.TimeUnit = model.TimeUnit;
    Gm.Ts = model.Ts;
    fig = figure; pzplot(Gm);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_pzplot_after.eps", 'epsc');     

    % Direct simulation (comparison)
    [mag, phase] = bode(G, w);
    [y_ARMAX_dir, t_ARMAX_dir] = lsim(G, dataIn.phi{reentryPos}, ...
        dataIn.t{reentryPos});
    [magm, phasem] = bode(Gm, w);
    [y_ARMAX_dir_app, t_ARMAX_dir_app] = lsim(Gm, dataIn.phi{reentryPos}, ...
        dataIn.t{reentryPos});
    phasem2 = squeeze(phasem) + round((phase(1,1,1)-phasem(1,1,1))/360)*360;

    % Frequency comparison english
    fig = figure; subplot(2, 1, 1); hold on; 
    semilogx(w, mag2db(squeeze(mag)), 'b', LineWidth=2.1);
    semilogx(w, mag2db(squeeze(magm)), '--r' , LineWidth=2.1);
    ylabel("Magnitude (dB)", Interpreter='latex', FontSize=17);
    set(gca, 'XScale', 'log'); grid minor; hold off; 
    subplot(2, 1, 2); hold on;
    h1 = semilogx(w, squeeze(phase), 'b', Linewidth=1.7, ...
        DisplayName="Identified model");
    h2 = semilogx(w, phasem2, '--r' , LineWidth=1.7, ...
        DisplayName="Approximated model");
    hold off; set(gca, 'XScale', 'log'); grid minor;
    ylabel("Phase (deg)", Interpreter='latex', FontSize=17);
    xlabel("Frequency (rad/s)", Interpreter='latex', FontSize=17);
    legend(Location='southwest', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_freq_reentry_en.eps", 'epsc');    

    % Frequency comparison french
    xlabel("Fr\'{e}quence (rad/s)", Interpreter='latex', FontSize=17);
    set(h1, "DisplayName", "Mod\`{e}le optimis\'{e}");
    set(h2, "DisplayName", "Mod\`{e}le approxim\'{e}");
    subplot(2, 1, 1); 
    ylabel("Module (dB)", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_freq_reentry_fr.eps", 'epsc');
    title({"Approximation par minimum de", "en fr\'{e}quence"}, ...
        Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_freq_reentry_fr.fig");

    % Time comparison
    fig = figure; hold on;
    plot(dataIn.t{reentryPos}/60e3, dataIn.y_back{reentryPos}, ...
        'ok', Linewidth=1.2, HandleVisibility='off', MarkerSize=1, ...
        MarkerFaceColor='k'); 
    h(1) = plot(NaN, NaN, 'ok', Linewidth=1.2, DisplayName="Exp. data",...
        MarkerSize=7, MarkerFaceColor='k'); 
    h(2) = plot(t_ARMAX_dir/60e3, y_ARMAX_dir, 'b', LineWidth=1.7, ...
        DisplayName="Identified model"); 
    h(3) = plot(t_ARMAX_dir_app/60e3, y_ARMAX_dir_app, '--r', ...
        LineWidth=1.7, DisplayName="Approximated model"); 
    hold off; grid minor;
    xlabel("Time (min)", Interpreter='latex', FontSize=17);
    ylabel("Temperature ($^\circ$)", Interpreter='latex', FontSize=17);
    legend(h, Location='southeast', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_en.eps", 'epsc');

    % Time comparison french
    xlabel("Temps (min)", Interpreter='latex', FontSize=17);
    ylabel("Temp\'{e}rature ($^\circ$)", Interpreter='latex', FontSize=17);
    set(h(2), "DisplayName", "Mod\`{e}le identifi\'{e}");
    set(h(3), "DisplayName", "Mod\`{e}le approxim\'{e}");
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_fr.eps", 'epsc');
    title({"Approximation par minimum de", "dans le temps"}, ...
        Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_fr.fig");
    
    %% Inverse model (valid)

    % TF
    Gm_inv = 1/Gm;
    Gm_inv.TimeUnit = model.TimeUnit;
    Gm_inv.Ts = model.Ts;
    
    % Inverse simulation (comparison for last valid data)
    y_back{validPos} = lowpass(dataIn.y_back{validPos}, 1e-2);
    [phi_ARMAX_inv, t_ARMAX_inv] = lsim(Gm_inv, y_back{validPos}, ...
        dataIn.t{validPos});
    phi_ARMAX_inv = medfilt1(lowpass(phi_ARMAX_inv(1:end-50), 1e-2), 5);

    % delay
    nk = sum(model.B == 0);
    ts = t_ARMAX_inv(2) - t_ARMAX_inv(1);
    t_ARMAX_inv = t_ARMAX_inv(1:end-50) - ts*nk;

    % Time comparison for last valid data english
    fig = figure; hold on; clear h;
    h(1) = plot(t_ARMAX_inv/60e3, phi_ARMAX_inv, 'r', LineWidth=1.7, ...
        DisplayName="Approximated model"); 
    plot(dataIn.t{validPos}/60e3, dataIn.phi{validPos}, 'ok', ...
        Linewidth=.8, HandleVisibility='off', MarkerSize=1, ...
        MarkerFaceColor='k');
    h(2) = plot(NaN, NaN, 'ok', Linewidth=.8, DisplayName="Exp. data", ...
        MarkerSize=7, MarkerFaceColor='k');
    hold off; grid minor;
    xlabel("Time (min)", Interpreter='latex', FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    legend(h, Location='southeast', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_valid_inv_en.eps", 'epsc');

    % Time comparison for last valid data french
    xlabel("Temps (min)", Interpreter='latex', FontSize=17);
    ylabel("Flux de chaleur (W/m$^2$)", Interpreter='latex', FontSize=17);
    set(h(1), "DisplayName", "Mod\`{e}le approxim\'{e}");
    set(h(2), "DisplayName", "Donn\'{e}es exp\'{e}rimentales");
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_valid_inv_fr.eps", 'epsc');
    title({"Inversion pour les donn\'{e}es", "exp\'{e}rimentales"}, ...
        Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_valid_inv_fr.fig");

    %% Inverse model (reentry)

    % Input and output figure (english)
    fig = figure; subplot(2, 1, 1);
    plot(dataIn.t{reentryPos}/60e3, dataIn.phi{reentryPos}, 'r', ...
        LineWidth=1.7);
    ylabel({"Heat flux", "(W/m$^2$)"}, Interpreter='latex', ...
        FontSize=17);
    grid minor; subplot(2, 1, 2);
    plot(dataIn.t{reentryPos}/60e3, dataIn.y_back{reentryPos}, 'r', ...
        LineWidth=1.7);
    grid minor;
    xlabel("Time (min)", Interpreter='latex', FontSize=17);
    ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_reentry_inputOutput_en.eps", 'epsc');

    % Input and output figure french
    ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter='latex', FontSize=17);
    xlabel("Temps (min)", Interpreter='latex', FontSize=17);
    subplot(2, 1, 1);
    ylabel({"Flux de chaleur", "(W/m$^2$)"}, Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_reentry_inputOutput_fr.eps", 'epsc');
    title("Entr\'{e}e et sortie", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_reentry_inputOutput_fr.fig");
    
    % Inverse simulation (comparison for reentry data)
    y_back = lowpass(dataIn.y_back{reentryPos}, 1e-3);
    [phi_ARMAX_inv, t_ARMAX_inv] = lsim(Gm_inv, y_back, ...
        dataIn.t{reentryPos});
    t_ARMAX_inv = t_ARMAX_inv - ts*nk;

    % Time comparison for reentry data english
    fig = figure; hold on; clear h;
    h(1) = plot(t_ARMAX_inv(1:end-50)/60e3, phi_ARMAX_inv(1:end-50), ...
        'r', LineWidth=1.7, DisplayName="Approximated model"); 
    plot(dataIn.t{reentryPos}(1:end-50)/60e3, dataIn.phi{reentryPos}(1:end-50), ...
        'ok', Linewidth=.8, HandleVisibility='off', MarkerSize=1, ...
        MarkerFaceColor='k');
    h(2) = plot(NaN, NaN, 'ok', Linewidth=.8, DisplayName="Exp. data", ...
        MarkerSize=7, MarkerFaceColor='k');
    hold off; grid minor;
    xlabel("Time (min)", Interpreter='latex', FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    legend(h, Location='southeast', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_inv_en.eps", 'epsc');

    % Time comparison for reentry data french
    xlabel("Temps (min)", Interpreter='latex', FontSize=17);
    ylabel("Flux de chaleur (W/m$^2$)", Interpreter='latex', FontSize=17);
    set(h(1), "DisplayName", "Mod\`{e}le identifi\'{e}");
    set(h(2), "DisplayName", "Donn\'{e}es exp\'{e}rimentales");
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_inv_fr.eps", 'epsc');
    title("Mod\'{e}le inverse non filtr\'{e}e", Interpreter='latex', ...
        FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_inv_fr.fig");

    %% Down sample and filtering

    phi_ARMAX_inv = downsample(phi_ARMAX_inv, 5);
    t_ARMAX_inv = downsample(t_ARMAX_inv, 5);

    phi_ARMAX_inv = medfilt1(lowpass(phi_ARMAX_inv(1:end-50), 1e-3),5);
    t_ARMAX_inv = t_ARMAX_inv(1:end-50);

    % Time comparison for reentry data english
    fig = figure; hold on; clear h;
    h(1) = plot(t_ARMAX_inv/60e3, phi_ARMAX_inv, 'r', LineWidth=1.7, ...
        DisplayName="Approximated model"); 
    plot(dataIn.t{reentryPos}/60e3, dataIn.phi{reentryPos}, 'ok', Linewidth=.8, ...
        HandleVisibility='off', MarkerSize=1, MarkerFaceColor='k');
    h(2) = plot(NaN, NaN, 'ok', Linewidth=.8, DisplayName="Exp. data", ...
        MarkerSize=7, MarkerFaceColor='k');
    hold off; grid minor;
    xlabel("Time (min)", Interpreter='latex', FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    legend(h, Location='southeast', Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_invPlus_en.eps", 'epsc');

    % Time comparison for reentry data french
    xlabel("Temps (min)", Interpreter='latex', FontSize=17);
    ylabel("Flux de chaleur (W/m$^2$)", Interpreter='latex', FontSize=17);
    set(h(1), "DisplayName", "Mod\`{e}le identifi\'{e}");
    set(h(2), "DisplayName", "Donn\'{e}es exp\'{e}rimentales");
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_invPlus_fr.eps", 'epsc');
    title("Mod\'{e}le inverse filtr\'{e}e", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + ...
        "\inversion\ARMAX_time_reentry_invPlus_fr.fig");

    % Output
    phi = phi_ARMAX_inv;
    t_out = t_ARMAX_inv;

    %% Ending and output
    if ~analysis.direct
        msg = 'Press enter to continue...';
        input(msg);
        fprintf(repmat('\b', 1, length(msg)+1));
    end
    close all;

end