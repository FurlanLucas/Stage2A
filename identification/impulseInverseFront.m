function [temp, t_out] = impulseInverseFront(dataIn, analysis, model, ...
    phi_)
    %% impulseInverse
    %
    % 

    %% Inputs
    figDir = analysis.figDir;      % Output figures directory
    analysisName = analysis.name;  % Analysis name

    % Other inputs
    reentryPos = dataIn.isReentry(end);

    %% Main

    % General data
    t = dataIn.t{reentryPos};
    y = dataIn.y_back{reentryPos};

    % Transfer function
    G = tf(model.B, model.A, model.Ts);
    G.TimeUnit = model.TimeUnit;
    dt = model.Ts;

    % Impulse response
    g = impulse(G, dataIn.t{reentryPos});

    fig = figure; pos = fix(length(t)/6);
    plot(t(1:pos)/60e3, g(1:pos), 'r', LineWidth=1.4);
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter="latex", FontSize=17);
    grid minor;
    saveas(fig, figDir+"\"+analysisName+"\ImpulseResponse.eps", 'epsc');

    fig = figure; hold on;
    y_ = dt*conv(g, phi_);
    plot(t, dataIn.y_front{reentryPos}, 'k', LineWidth=1.5);
    plot(t, y_(1:length(t)), 'r', LineWidth=1.5);
    grid minor;
    xlabel('Time (min)', Interpreter="latex", FontSize=17);
    ylabel('Temperature ($^\circ$C)', Interpreter="latex", FontSize=17);
    saveas(fig, figDir+"\"+analysisName+"\ImpulseTempInv.eps", 'epsc');

    %% Output
    temp = y_(1:length(t));
    t_out = t;

end