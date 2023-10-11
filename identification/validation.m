function resid = validation(dataIn, analysis, models, varargin)
    %% validation
    %
    % Function to validate the models identified in convergence. It will be
    % used the data in dataIn to calculate the autocorrelation and
    % intercorrelation between the error estimative and input command.
    %
    % Calls
    %
    %   resid = validation(dataIn, models): validate the models in the
    %   structure models, using the data avaiable in dataIn. It will be
    %   used all the datasets except for the first one;
    %
    %   analysis: struct with analysis' name, graph colors and output
    %   directories;
    %
    %   resid = validation(__, options): take the optional arguments.
    %
    % Inputs
    %
    %   dataIn: thermalData variable with all the information for the
    %   system that will be simulated.
    %
    %   models: struct with the models to be validated. For instance, with
    %   the filds named: ARX, OE, ARMAX and BJ.
    %
    % Outputs
    %
    %   resid: residue from the analysis.
    %
    % Aditional options
    %
    %   setExp: set the number of experiments to be used in the validation
    %   analysis. The result of validation(dataIn, models, setExp=[1,2]) is
    %   the same of validation(getexp(dataIn, [1,2]), models);
    %
    %   type: identifies the outputdata to be considered. By default,
    %   type=1 specifies that will be used the back measured temperature
    %   and type=2 specifies the front temperature;
    %
    %   M: maximum lag number t be consider in correlation analysis.
    %
    % See convergence, iddata, sysDataType, thermalData.

    %% Inputs

    % Graph settings
    probChi = analysis.probChi;   % Propability for 99 % xi² dist.
    probNorm = analysis.probNorm; % Propability for 99 % N dist.
    Mksize = analysis.Mksize;     % Marker size

    % Defaults inputs
    type = 1;
    M = 25;                       % Max lag to the correlation
    
    % Optional inputs
    for i=1:2:length(varargin)        
        switch varargin{i}
            case 'setExp'
                dataIn = getexp(dataIn, varargin{i+1});
            case 'type'
                type = varargin{i+1};
            case 'M'
                M = varargin{i+1};
            case 'straight'
                straight = varargin{i+1};
        end
    end

    if type == 1
        myDir = analysis.figDir + "\" + analysis.name + "\validation_flux";
    elseif type == 2
        myDir = analysis.figDir + "\" + analysis.name + "\validation_temp";
    else
        error("Type not available.");
    end

    if ~isfolder(myDir)
        mkdir(myDir);
    end

    %% Variable initialization

    % Identified models
    n_data = size(dataIn, 4); % Number of experiments 
    sysARX = models.ARX;
    sysOE= models.OE;
    sysARMAX = models.ARMAX;
    sysBJ = models.BJ;    

    % Outputs
    resid.OE = cell(n_data, 1);
    resid.ARX = cell(n_data, 1);
    resid.ARMAX = cell(n_data, 1);
    resid.BJ = cell(n_data, 1);

    %% Main part
    for i = 1:n_data

        fprintf("\tAnalysis for set %s.\n",dataIn.ExperimentName{i});
        validData = getexp(dataIn, i);
        validData.y = validData.y(:,type); % Take one output only
        t = validData.SamplingInstants/60e3; % Temps en minutes
        y = validData.y; % Vrai sortie (mesurée)
        N = length(validData.y);

        % Input correlation
        Ruu = xcorr(validData.u, M, 'biased');
        
        %% OE model
        y_oe = lsim(sysOE, validData.u);
        e_oe = validData.y - y_oe;
        resid.OE{i} = e_oe;

        % Correlations
        [Ree_oe, Lee_oe] = xcorr(e_oe, M, 'biased');
        [Rue_oe, Lue_oe] = xcorr(e_oe, validData.u, M, 'biased');
        P1_oe = abs(Ruu' * Ree_oe);

        % Confidence region
        confRauto = probChi/sqrt(N);
        confRinter = probNorm*sqrt(P1_oe)/sqrt(Ree_oe(M+1)*Ruu(M+1)*N);

        % Both correlation figures (OE model) - FR
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_oe, Ree_oe/Ree_oe(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_oe, Rue_oe/sqrt(Ree_oe(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\valid_correlation_OE_fr" + num2str(i) + ...
            ".eps", 'epsc');
        sgtitle("Mod\'{e}le OE (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
        saveas(fig, myDir + "\valid_correlation_OE_fr" + ...
            num2str(i) + ".fig");

        % Auto-correlation figure (OE model) - EN
        fig = figure;
        stem(Lee_oe, Ree_oe/Ree_oe(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_autocorrelation_OE_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;

        % Intercorrelation figure (OE model) - EN
        fig = figure;
        stem(Lue_oe, Rue_oe/sqrt(Ree_oe(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_intercorrelation_OE_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;
    
        % Whiteness test - EN
        fig = figure; handleT = tiledlayout(3,1,'TileSpacing','Compact');
        nexttile, plot(t, e_oe, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(t)]);
        xlabel('Time (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(y_oe, e_oe, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(y_oe)]);
        xlabel('Temperature (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(validData.u, e_oe, 'or', MarkerSize=0.5, ...
            MarkerFaceColor='r');
        xlabel('Heat flux (W/m$^2$)', Interpreter='latex', FontSize=17);
        ylabel(handleT, 'Error ($^\circ$C)', Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\errorDist_OE_en" + num2str(i) + ".eps", 'epsc');
        saveas(fig, myDir + "\errorDist_OE_en" + num2str(i) + ".fig");
        close;

        % Time only
        fig = figure; hold on; h = [];
        plot(t, y, 'ok',MarkerSize=0.8,...
            MarkerFaceColor='k');
        h(1) = plot(t,y_oe,"-r",LineWidth=1,DisplayName='OE model');
        h(2) = plot(NaN,NaN,'ok',MarkerSize=7,...
            MarkerFaceColor='k',DisplayName="Exp. data");
        ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
        xlabel("Time (min)", Interpreter='latex', FontSize=17);
        legend(h, Location="southeast", Interpreter="latex", FontSize=17);
        grid minor;
        saveas(fig, myDir + "\validTime_OE_en" + num2str(i) + ".eps", 'epsc');
        saveas(fig, myDir + "\validTime_OE_en" + num2str(i) + ".fig");

        %% ARX model
        y_arx = lsim(sysARX, validData.u);
        e_arx = validData.y - y_arx;
        resid.ARX{i} = e_arx;
        noiseModel = idpoly(1,sysARX.A,1,1,1,sysARX.NoiseVariance,sysARX.Ts);
        e_arx = lsim(noiseModel, e_arx);

        % Correlations
        [Ree_arx, Lee_arx] = xcorr(e_arx, M, 'biased');
        [Rue_arx, Lue_arx] = xcorr(e_arx, validData.u, M, 'biased');
        P1_arx = abs(Ruu' * Ree_arx);

        % Confidence region
        confRauto = probChi/sqrt(N);
        confRinter = probNorm*sqrt(P1_arx)/sqrt(Ree_arx(M+1)*Ruu(M+1)*N);

        % Both correlation figures (ARX model) - FR
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_arx, Ree_arx/Ree_arx(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_arx, Rue_arx/sqrt(Ree_arx(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\valid_correlation_ARX_" + num2str(i) + ...
            ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);

        % Autocorrelation figure (ARX model) - EN
        fig = figure;
        stem(Lee_arx, Ree_arx/Ree_arx(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_autocorrelation_ARX_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;

        % Intercorrelation figure (ARX model) - EN
        fig = figure;
        stem(Lue_arx, Rue_arx/sqrt(Ree_arx(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_intercorrelation_ARX_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;
    
        % Whiteness test - EN
        fig = figure; handleT = tiledlayout(3,1,'TileSpacing','Compact');
        nexttile, plot(t, e_arx, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(t)]);
        xlabel('Time (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(y_arx, e_arx, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(y_arx)]);
        xlabel('Temperature (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(validData.u, e_arx, 'or', MarkerSize=0.5, ...
            MarkerFaceColor='r');
        xlabel('Heat flux (W/m$^2$)', Interpreter='latex', FontSize=17);
        ylabel(handleT, 'Error ($^\circ$C)', Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\errorDist_ARX_en" + num2str(i) + ...
            ".eps", 'epsc');
        close;

        % Time only
        fig = figure; hold on; h = [];
        plot(t, y, 'ok',MarkerSize=0.8,...
            MarkerFaceColor='k');
        h(1) = plot(t,y_arx,"-r",LineWidth=1,DisplayName='ARX model');
        h(2) = plot(NaN,NaN,'ok',MarkerSize=7,...
            MarkerFaceColor='k',DisplayName="Exp. data");
        ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
        xlabel("Time (min)", Interpreter='latex', FontSize=17);
        legend(h, Location="southeast", Interpreter="latex", FontSize=17);
        grid minor;
        saveas(fig, myDir + "\validTime_ARX_en" + num2str(i) + ...
            ".eps", 'epsc');

        %% ARMAX model
        y_armax = lsim(sysARMAX, validData.u);
        e_armax = validData.y - y_armax;
        resid.ARMAX{i} = e_armax;
        noiseModel = idpoly(1,sysARMAX.A,1,1,sysARMAX.C, ...
            sysARMAX.NoiseVariance,sysARMAX.Ts);
        e_armax = lsim(noiseModel, e_armax);

        % Correlations
        [Ree_armax, Lee_armax] = xcorr(e_armax, M, 'biased');
        [Rue_armax, Lue_armax] = xcorr(e_armax, validData.u, M, 'biased');
        P1_armax = abs(Ruu' * Ree_armax);

        % Confidence region
        confRauto = probChi/sqrt(N);
        confRinter = probNorm*sqrt(P1_armax)/sqrt(Ree_armax(M+1)*Ruu(M+1)*N);

        % Both correlation figures (ARMAX model) - FR
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_armax, Ree_armax/Ree_armax(M+1), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_armax, Rue_armax/sqrt(Ree_armax(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\valid_correlation_ARMAX_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARMAX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
        
        % Intercorrelation figure (ARMAX model) - EN
        fig = figure;
        stem(Lee_armax, Ree_armax/Ree_armax(M+1), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_autocorrelation_ARMAX_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;
        
        % Autocorrelation figure (ARMAX model) - EN
        fig = figure;
        stem(Lue_armax, Rue_armax/sqrt(Ree_armax(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_intercorrelation_ARMAX_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;

        % Whiteness test - EN
        fig = figure; handleT = tiledlayout(3,1,'TileSpacing','Compact');
        nexttile, plot(t, e_armax, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(t)]);
        xlabel('Time (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(y_armax, e_armax, 'or', MarkerSize=0.5, ...
            MarkerFaceColor='r');
        xlim([0, max(y_armax)]);
        xlabel('Temperature (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(validData.u, e_armax, 'or', MarkerSize=0.5, ...
            MarkerFaceColor='r');
        xlabel('Heat flux (W/m$^2$)', Interpreter='latex', FontSize=17);
        ylabel(handleT, 'Error ($^\circ$C)', Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\errorDist_ARMAX_en" + num2str(i) + ...
            ".eps", 'epsc');
        close;

        % Time only
        fig = figure; hold on; h = [];
        plot(t, y, 'ok',MarkerSize=0.8,...
            MarkerFaceColor='k');
        h(1) = plot(t,y_armax,"-r",LineWidth=1,DisplayName='ARMAX model');
        h(2) = plot(NaN,NaN,'ok',MarkerSize=7,...
            MarkerFaceColor='k',DisplayName="Exp. data");
        ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
        xlabel("Time (min)", Interpreter='latex', FontSize=17);
        legend(h, Location="southeast", Interpreter="latex", FontSize=17);
        grid minor;
        saveas(fig, myDir + "\validTime_ARMAX_en" + num2str(i) + ...
            ".eps", 'epsc');

        %% BJ model
        y_bj = lsim(sysBJ, validData.u);
        e_bj = validData.y - y_bj;
        resid.BJ{i} = e_bj;
        noiseModel = idpoly(sysBJ.C,sysBJ.D,1,1,1, ...
            sysBJ.NoiseVariance, sysBJ.Ts);
        e_bj = lsim(noiseModel, e_bj);

        % Correlations
        [Ree_bj, Lee_bj] = xcorr(e_bj, M, 'biased');
        [Rue_bj, Lue_bj] = xcorr(e_bj, validData.u, M, 'biased');
        P1_bj = abs(Ruu' * Ree_bj);

        % Confidence region
        confRauto = probChi/sqrt(N);
        confRinter = probNorm*sqrt(P1_bj/(Ree_bj(M+1)*Ruu(M+1)*N));

        % Both correlation figures (BJ model) - FR
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_bj, Ree_bj/Ree_bj(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_bj,Rue_bj/sqrt(Ree_bj(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\valid_correlation_BJ_" + num2str(i) + ...
            ".eps", 'epsc');
        sgtitle("Mod\'{e}le BJ (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);

        % Autocorrelation figure (BJ model) - EN
        fig = figure;
        stem(Lee_bj, Ree_bj/Ree_bj(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_autocorrelation_BJ_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;

        % Intercorrelation figure (BJ model) - EN
        fig = figure;
        stem(Lue_bj,Rue_bj/sqrt(Ree_bj(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.2, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        xlabel("Lag", Interpreter='latex', FontSize=17);
        grid minor;
        saveas(fig, myDir + "\valid_intercorrelation_BJ_en" + ...
            num2str(i) + ".eps", 'epsc');
        close;

        % Whiteness test - EN
        fig = figure; handleT = tiledlayout(3,1,'TileSpacing','Compact');
        nexttile, plot(t, e_bj, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(t)]);
        xlabel('Time (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(y_bj, e_bj, 'or', MarkerSize=0.5, MarkerFaceColor='r');
        xlim([0, max(y_bj)]);
        xlabel('Temperature (min)', Interpreter='latex', FontSize=17);
        nexttile, plot(validData.u, e_bj, 'or', MarkerSize=0.5, ...
            MarkerFaceColor='r');
        xlabel('Heat flux (W/m$^2$)', Interpreter='latex', FontSize=17);
        ylabel(handleT, 'Error ($^\circ$C)', Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\errorDist_BJ_en" + num2str(i) + ".eps", 'epsc');
        close;

        % Time only
        fig = figure; hold on; h = [];
        plot(t, y, 'ok',MarkerSize=0.8,...
            MarkerFaceColor='k');
        h(1) = plot(t,y_bj,"-r",LineWidth=1,DisplayName='BJ model');
        h(2) = plot(NaN,NaN,'ok',MarkerSize=7,...
            MarkerFaceColor='k',DisplayName="Exp. data");
        ylabel("Temperature ($^\circ$C)", Interpreter='latex', FontSize=17);
        xlabel("Time (min)", Interpreter='latex', FontSize=17);
        legend(h, Location="southeast", Interpreter="latex", FontSize=17);
        grid minor;
        saveas(fig, myDir + "\validTime_BJ_en" + num2str(i) + ".eps", 'epsc');
    
        %% Time data figure (all models)
        fig = figure; hold on;
        plot(t, y, 'k',LineWidth=1.4,DisplayName="Donn\'{e}es");
        plot(t, y_oe, "-r",LineWidth=2,DisplayName='Mod\`{e}le OE');
        plot(t, y_arx, "--g",LineWidth=2,DisplayName='Mod\`{e}le ARX');
        plot(t, y_armax, "-.b",LineWidth=2,DisplayName='Mod\`{e}le ARMAX');
        plot(t, y_bj, ":y",LineWidth=2, DisplayName='Mod\`{e}le BJ');
        grid minor; 
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
        legend(Location='southeast', Interpreter='latex', FontSize=17);
        saveas(fig, myDir + "\comp_temps" + num2str(i) + ".eps", 'epsc');       

        if i == n_data && ~analysis.direct
            msg = 'Press any key to continue...';
            input(msg);
            fprintf(repmat('\b', 1, length(msg)+1));
        end

        % Close all figures
        close all;
    end

    % Résultats (a être implanté)
    %resid = NaN;

end