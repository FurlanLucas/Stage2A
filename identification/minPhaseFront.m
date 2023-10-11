function [temp, t_out] = minPhaseFront(dataIn, analysis, model, G_inv)
    %% minPhaseFront
    %
    % Function to invert the model and validate it with reentry data. The
    % input will be tha last experiment available in dataIn as a reentry
    % data. The inversion is done by minimum phase approximation.
    %
    % Calls
    %
    %   [phi, t_out] = minPhaseBack(dataIn, analysis, model, G_inv):
    %   estimate the heat flux phi during the time t_out by using the
    %   minimum phase approximation.
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
    %   model: model to be inverted (will be a front model, with respect to
    %   the temperature measured in front face);
    %
    %   G_inv: inverse system's transfer function (with respect to the heat
    %   flux).
    %
    % Outputs
    %
    %   phi: vector of estimated heat flux;
    %
    %   t_out: output time.
    %
    % See convergence, iddata, sysDataType, thermalData.

    %% Inputs
    figDir = analysis.figDir;          % Directory for output figures
    analysisName = dataIn.Name; % Analysis name 

    %% Direct system's model

    G = tf(model.B, model.A, model.Ts);
    G.TimeUnit = model.TimeUnit;

    %% Inverse model (reentry)
    
    % Inverse simulation (comparison for reentry data)
    y_back = lowpass(dataIn.y_back{end}, 1e-3);
    [temp_ARMAX_inv, t_ARMAX_inv] = lsim(G_inv*G, y_back, ...
        dataIn.t{end});

    % Time comparison for reentry data english
    fig = figure; hold on; clear h;
    h(1) = plot(t_ARMAX_inv(1:end-50)/60e3, temp_ARMAX_inv(1:end-50), ...
        'r', LineWidth=1.7, DisplayName="Approximated model"); 
    plot(dataIn.t{end}(1:end-50)/60e3, dataIn.y_front{end}(1:end-50), ...
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

    %% Down sample and filtering

    temp_ARMAX_inv = downsample(temp_ARMAX_inv, 5);
    t_ARMAX_inv = downsample(t_ARMAX_inv, 5);

    temp_ARMAX_inv = medfilt1(lowpass(temp_ARMAX_inv, 1e-3),5);
    temp_ARMAX_inv = temp_ARMAX_inv(1:end-20);
    t_ARMAX_inv = t_ARMAX_inv(1:end-20);

    % Time comparison for reentry data english
    fig = figure; hold on; clear h;
    h(1) = plot(t_ARMAX_inv/60e3, temp_ARMAX_inv, 'r', LineWidth=1.7, ...
        DisplayName="Approximated model"); 
    plot(dataIn.t{end}/60e3, dataIn.y_front{end}, 'ok', Linewidth=.8, ...
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

    % Output
    temp = temp_ARMAX_inv;
    t_out = t_ARMAX_inv;

    %% Ending and output
    
    if ~analysis.direct
        msg = 'Press enter to continue...';
        input(msg);
        fprintf(repmat('\b', 1, length(msg)+1));
    end

end