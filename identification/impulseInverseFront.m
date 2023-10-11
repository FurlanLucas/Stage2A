function [temp, t_out] = impulseInverseFront(dataIn, analysis, model, ...
    phi_)
    %% impulseInverseFront
    %
    % Function to invert the model and validate it with reentry data. The
    % input will be tha last experiment available in dataIn as a reentry
    % data. The inversion is done by simple convolution with the future
    % time steps results.
    %
    % Calls
    %
    %   [temp, t_out] = impulseInverseFront(dataIn, analysis, model,
    %   phi_): estimate the temperature during the time t_out by using a
    %   convolution with the future time steps results.
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
    %   the temperature in front face);
    %
    %   phi_: estimated heat flux.
    %
    % Outputs
    %
    %   temp: vector of estimated temperature;
    %
    %   t_out: output time.
    %
    % See convergence, iddata, sysDataType, thermalData.

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