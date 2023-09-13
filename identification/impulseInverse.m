function [phi, t_out] = impulseInverse(expData, models)
    %% impulseInverse
    %
    % 

    %% Inputs
    figDir = 'outFig';      % Output figures directory
    analysisNumber = 1;     % Analysis number (to be tested)
    r = [30, 70];           % Samplings to be predict

    % Other inputs
    analysisName = expData.Name;

    %% Main

    % General data
    t = expData.t{analysisNumber};
    y = expData.y_back{analysisNumber};

    % Transfer function
    G = tf(models.ARMAX.B, models.ARMAX.A, models.ARMAX.Ts);
    G.TimeUnit = models.ARMAX.TimeUnit;
    dt = models.ARX.Ts;

    % Impulse response
    g = impulse(G, expData.t{analysisNumber});

    fig = figure; pos = fix(length(t)/6);
    plot(t(1:pos)/60e3, g(1:pos), 'r', LineWidth=1.4);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel('Temperature ($^\circ$C)', Interpreter="latex", FontSize=17);
    grid minor;
    saveas(fig, figDir+"\"+analysisName+"\ImpulseResponse.eps", 'epsc');

    fig = figure; hold on;
    y_ = dt*conv(g, expData.phi{analysisNumber});
    plot(t, y_(1:length(t)), 'r', LineWidth=1.5);
    plot(t, y, '--b', LineWidth=1.5);
    grid minor;

    ym = expData.y_back{end};
    t = expData.t{end};
    u1 = imp2phi(ym, g, r(1), dt);
    u2 = imp2phi(ym, g, r(2), dt);

    fig = figure; hold on;
    plot(t/60e3, u1, 'b', LineWidth=1.5, DisplayName="$r="+...
        num2str(r(1))+"$");
    plot(t/60e3, u2, 'r', LineWidth=1.5, DisplayName="$r="+...
        num2str(r(2))+"$");
    plot(t/60e3, expData.phi{end}, 'k', LineWidth=1.5, ...
        DisplayName="Exp. data");
    legend(Location='south', Interpreter='latex', FontSize=17);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Heat flux (W/m$^2$)", Interpreter='latex', FontSize=17);
    grid minor;
    saveas(fig, figDir+"\"+analysisName+"\heatFluxImpulse.eps", 'epsc');

    %% Output
    phi = u2;
    t_out = t;

end