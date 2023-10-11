function [phi, t_out] = impulseInverse(expData, analysis, model)
    %% impulseInverse
    %
    % 

    %% Inputs
    figDir = analysis.figDir;  % Output figures directory
    r = [30, 70];              % Samplings to be predict

    % Other inputs
    analysisName = expData.Name;
    analysisNumber = expData.isReentry(end);  % Analysis number (to be tested)

    %% Main

    % General data
    t = expData.t{analysisNumber};
    y = expData.y_back{analysisNumber};

    % Transfer function
    G = tf(model.B, model.A, model.Ts);
    G.TimeUnit = model.TimeUnit;
    dt = model.Ts;

    % Impulse response
    g = impulse(G, expData.t{analysisNumber});

    fig = figure; pos = fix(length(t)/6);
    plot(t(1:pos)/60e3, g(1:pos), 'r', LineWidth=1.4);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel('Temperature ($^\circ$C)', Interpreter="latex", FontSize=17);
    grid minor;
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\ImpulseResponse.eps", 'epsc');

    fig = figure; hold on;
    y_ = dt*conv(g, expData.phi{analysisNumber});
    plot(t, y_(1:length(t)), 'r', LineWidth=1.5);
    plot(t, y, '--b', LineWidth=1.5);
    grid minor;

    ym = expData.y_back{analysisNumber};
    t = expData.t{analysisNumber};
    u1 = imp2phi(ym, g, r(1), dt);
    u2 = imp2phi(ym, g, r(2), dt);

    % Figure EN
    fig = figure; hold on;
    plot(t/60e3, u1, 'b', LineWidth=1.5, DisplayName="$k="+...
        num2str(r(1))+"$");
    plot(t/60e3, u2, 'r', LineWidth=1.5, DisplayName="$k="+...
        num2str(r(2))+"$");
    myplot = plot(t/60e3, expData.phi{analysisNumber}, 'k', ...
        LineWidth=1.5, DisplayName="Exp. data");
    legend(Location='south', Interpreter='latex', FontSize=17);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    grid minor;
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\heatFluxImpulse_en.eps", 'epsc');

    % Figure FR
    set(myplot, 'DisplayName', "Donn\'{e}es exp\'{e}perimentales");
    xlabel('Temps (min)', Interpreter="latex", FontSize=17);
    ylabel("Flux de chaleur (W/m$^2$)", Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\heatFluxImpulse_fr.eps", 'epsc');
    title("Flux de chaleur estim\'{e}e", ...
        Interpreter='latex', FontSize=17);
    saveas(fig, figDir + "\" + analysisName + "\inversion" + ...
        "\heatFluxImpulse_fr.fig");

    %% Output
    phi = u2;
    t_out = t;

end