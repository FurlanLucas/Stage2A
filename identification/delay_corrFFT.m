function delay_corrFFT(dataIn, analysis, type)
    %% delay_corrFFT
    %
    % Delay analysis by time observation, correlation analysis and FFT
    % transforms. 
    %
    % Calls
    %
    %   delay_corrFFT(dataIn, analysis, type): calculates and shows the
    %   delay for a correlation and FFT analysis. Also, displays the time
    %   observation for which the delay can be deduced.
    %
    % Inputs
    %
    %   dataIn: thermalData object with all datasets to be analysed;
    %s
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   type: switch between back temperature analysis for type=1 and 
    %   front temperature analysis for type=2.
    %
    % See also thermalData, Contents, AnalysisSettings.

    %% Inputs
    colors = analysis.colors;
    outDir = analysis.figDir;
    analysisName = analysis.name;

    % Numerical inputs
    samp = 30;         % Number of saples to take the mean
    NbeforeMax = 1000; % Max samples to take before the input change

    if type == 1
        typeName = "flux";
    elseif type == 2
        typeName = "temp";
    else
        error("Type not valid.");
    end
    
    %% Main
    
    if ~isempty(dataIn.isStep)
        fig_all = figure; hold on;
    end

    for i = 1:length(dataIn.isStep)
        % Main inputs
        inter = getexp(dataIn, dataIn.isStep(i));
        u = inter.u;
        y = inter.y(:,type);
        t = inter.SamplingInstants;

        % Other inputs
        ts = t(2)-t(1);
        uMax = mean(u(fix(length(u)/2)-10:fix(length(u)/2)+10));
        pos0 = find(u>uMax/2, 1);
    
        t = t-t(pos0);
        y = y/uMax;
        y = y-mean(y(1:pos0));
    
        figure(fig_all.Number);
        uMaxString = "$u="+sprintf("%.0f", uMax/1e3)+"$ kW/m$^2$";
        plot(t, y, colors(i), DisplayName=uMaxString);

        % Time zoom
        if NbeforeMax <= pos0
            Nbefore = NbeforeMax;
        else
            Nbefore = pos0-1;
        end

        uM = [zeros(Nbefore,1); ones(2*Nbefore+1,1)];
        tM = t(pos0-Nbefore:pos0+2*Nbefore);
        yM = y(pos0-Nbefore:pos0+2*Nbefore);

        % Main zoom figure in english
        fig = figure;
        yyaxis left; plot(tM, yM, 'b', HandleVisibility='off'); hold on;
        mean_y = mean(yM(1:Nbefore));
        stddev_y = sqrt(var(yM(1:Nbefore)));
        plot(xlim(), mean_y + stddev_y*[1 1], '-.k', HandleVisibility='off');
        plot(xlim(), mean_y*[1 1], '-k', HandleVisibility='off');
        plot(xlim(), mean_y - stddev_y*[1 1], '-.k', HandleVisibility='off');
        myylim = ylim;
        ylabel("Temperature ($^\circ$C)", Interpreter='latex', ...
            FontSize=17);
        yyaxis right; 
        plot(tM, uM, 'r', LineWidth=2.3, HandleVisibility='off');
        ylabel("Input (W/m$^2$)", Interpreter='latex', FontSize=17);
        xlabel("Time (ms)", Interpreter='latex', FontSize=17);
        ylim(myylim*1.2/(myylim(2)-myylim(1)));
        xlim([-5000, 5000]);
        ax = gca;
        ax.YAxis(1).Color = 'b';
        ax.YAxis(2).Color = 'r';
        grid minor; yyaxis left;
        [new_ym, new_tm] = takeMean(yM, tM, samp);
        a = plot(new_tm, new_ym, '-g', LineWidth=1.7);
        legend({"Mean"}, Location='northwest', Interpreter="latex", ...
            FontSize=17);
        saveas(fig, outDir + "\" + analysisName + "\delay\stepZoom_" + ...
            i + "_" + typeName + "_en.eps", 'epsc');

        % Main zoom figure in english
        set(a, 'DisplayName', 'Moyenne');
        ylabel("Entr\'{e} (W/m$^2$)", Interpreter='latex', FontSize=17);
        xlabel("Temps (ms)", Interpreter='latex', FontSize=17);
        yyaxis left;
        ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter='latex', ...
            FontSize=17);
        saveas(fig, outDir + "\" + analysisName + "\delay\stepZoom_" + ...
            i + "_" + typeName + "_fr.eps", 'epsc');
        saveas(fig, outDir + "\" + analysisName + "\delay\stepZoom_" + ...
            i + "_" + typeName + "_fr.fig");

        %% Autocorrelation and FFT
    
        [R, lag] = xcorr(yM, uM, 'normalized'); 
    
        % Figure in english
        fig = figure;
        plot(lag, R, 'b', LineWidth=1.7); grid minor;
        xlabel("Lag", Interpreter="latex", FontSize=17);
        ylabel("Autocorrelation", Interpreter="latex", FontSize=17);
        saveas(fig, outDir + "\" + analysisName + "\delay" + ...
            "\delayCorr_" + typeName + "_en.eps", 'epsc');
    
        % Figure in french
        xlabel("Lag", Interpreter="latex", FontSize=17);
        ylabel("Autocorr\'{e}lation", Interpreter="latex", FontSize=17);
        saveas(fig, outDir + "\" + analysisName + "\delay" + ...
            "\delayCorr_" + typeName + "_fr.eps", 'epsc');
    
        [~, posMax] = max(R);   
        fprintf('Max pos autocorr: %d,\t', lag(posMax));
        fprintf('TR: %f ms\n', lag(posMax)*ts);
        
        % FFT 
        result_ifft = abs(ifft(fft(yM).*fft(uM)));
        [~, posMax] = max(result_ifft);
        
        fprintf('Max pos FFT: %d,\t', posMax);
        fprintf('TR: %f ms\n', tM(posMax));

    end
    
    % Figure with all plots in english
    figure(fig_all.Number);
    legend(Location="southeast", Interpreter="latex", FontSize=17);
    grid minor;
    ylabel("Temperature ($^\circ$C)", Interpreter='latex', ...
        FontSize=17);
    xlabel("Time (ms)", Interpreter='latex', FontSize=17);
    saveas(fig_all, outDir + "\" + analysisName + "\delay" + ...
        "\stepAll_" + typeName + "_en.eps", 'epsc');

    % Figure with all plots in french
    ylabel("Temp\'{e}rature ($^\circ$C)", Interpreter='latex', ...
        FontSize=17);
    xlabel("Temps (ms)", Interpreter='latex', FontSize=17);
    saveas(fig_all, outDir + "\" + analysisName + "\delay" + ...
        "\stepAll_" + typeName + "_fr.eps", 'epsc');
    title("Réponse indicielle");
    saveas(fig_all, outDir + "\" + analysisName + "\delay" + ...
        "\stepAll_" + typeName + "_fr.fig");

    %% Ending

    if ~analysis.direct
        msg = 'Press any key to continue...';
        input(msg);
        fprintf(repmat('\b', 1, length(msg)+3));
    end
    
    close all;

end

function [new_ym, new_tm] = takeMean(yM, tM, samp)
    % Function to take the mean of a signal over time. Equivalent to a low
    % pass filter.

    len = fix(length(yM)/samp);
    new_ym = zeros(len,1);
    new_tm = zeros(len,1);
    
    for i = 0:len-1
        init = i*samp+1;
        new_tm(i+1) = mean(tM(init:init+samp));
        new_ym(i+1) = mean(yM(init:init+samp));
    end
end