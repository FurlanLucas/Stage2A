function resid = validation(dataIn, models, varargin)
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
    %   the same of validation(getexp(dataIn, [1,2]), models).
    %
    % See convergence, iddata, sysDataType, thermalData.

    %% Inputs

    figDir = 'outFig';          % Directory for output figures
    analysisName = dataIn.Name; % Analysis name 
    M = 25;                     % Max lag to the correlation
    prob = 5.5758;              % Propability for 99 %
    Mksize = 3;                 % Marker size

    % Optional inputs
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("setExp")
                    dataIn = getexp(dataIn, varargin{arg, 2});
                    break;
            end
        end
    end

    % Identified models
    n_data = size(dataIn, 4); % Number of experiments 
    sysARX = models.ARX;
    sysOE= models.OE;
    sysARMAX = models.ARMAX;
    sysBJ = models.BJ;    

    % Main part
    for i = 1:n_data
        fprintf("\tAnalysis for set %s.\n",dataIn.ExperimentName{i});
        validData = getexp(dataIn, i);
        validData.y = validData.y(:,1); % Take one output only
        t = validData.SamplingInstants/60e3; % Temps en minutes
        y = validData.y; % Vrai sortie (mesurée)
        N = length(validData.y);

        % Input correlation
        Ruu = xcorr(validData.u, M, 'biased');
        
        %% OE model
        y_oe = lsim(sysOE, validData.u);
        e_oe = validData.y - y_oe;
        [Ree_oe, Lee_oe] = xcorr(e_oe, M, 'biased');
        [Rue_oe, Lue_oe] = xcorr(e_oe, validData.u, M, 'biased');
        P1_oe = abs(Ruu' * Ree_oe);

        % Confidence region
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_oe)/sqrt(Ree_oe(M+1)*Ruu(M+1)*N);

        % Correlation figure (OE model)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_oe, Ree_oe/Ree_oe(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_oe, Rue_oe/sqrt(Ree_oe(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName + "\valid_correlation_OE_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le OE (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% ARX model
        y_arx = lsim(sysARX, validData.u);
        e_arx = validData.y - y_arx;
        noiseModel = idpoly(1,sysARX.A,1,1,1,sysARX.NoiseVariance,sysARX.Ts);
        e_arx = lsim(noiseModel, e_arx);
        [Ree_arx, Lee_arx] = xcorr(e_arx, M, 'biased');
        [Rue_arx, Lue_arx] = xcorr(e_arx, validData.u, M, 'biased');
        P1_arx = abs(Ruu' * Ree_arx);

        % Confidence region
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_arx)/sqrt(Ree_arx(M+1)*Ruu(M+1)*N);

        % Correlation figure (ARX model)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_arx, Ree_arx/Ree_arx(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_arx, Rue_arx/sqrt(Ree_arx(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName + "\valid_correlation_ARX_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% ARMAX model
        y_armax = lsim(sysARMAX, validData.u);
        e_armax = validData.y - y_armax;
        noiseModel = idpoly(1,sysARMAX.A,1,1,sysARMAX.C, ...
            sysARMAX.NoiseVariance,sysARMAX.Ts);
        e_armax = lsim(noiseModel, e_armax);
        [Ree_armax, Lee_armax] = xcorr(e_armax, M, 'biased');
        [Rue_armax, Lue_armax] = xcorr(e_armax, validData.u, M, 'biased');
        P1_armax = abs(Ruu' * Ree_armax);

        % Confidence region
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_armax)/sqrt(Ree_armax(M+1)*Ruu(M+1)*N);

        % % Correlation figure (ARMAX model)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_armax, Ree_armax/Ree_armax(M+1), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_armax, Rue_armax/sqrt(Ree_armax(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName +"\valid_correlation_ARMAX_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARMAX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);

        %% BJ model
        y_bj = lsim(sysBJ, validData.u);
        e_bj = validData.y - y_bj;
        noiseModel = idpoly(sysBJ.C,sysBJ.D,1,1,1, ...
            sysBJ.NoiseVariance, sysBJ.Ts);
        e_bj = lsim(noiseModel, e_bj);
        [Ree_bj, Lee_bj] = xcorr(e_bj, M, 'biased');
        [Rue_bj, Lue_bj] = xcorr(e_bj, validData.u, M, 'biased');
        P1_bj = abs(Ruu' * Ree_bj);

        % Confidence region
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_bj/(Ree_bj(M+1)*Ruu(M+1)*N));

        % % Correlation figure (BJ model)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        stem(Lee_bj, Ree_bj/Ree_bj(M+1), 'or', MarkerSize=Mksize, ...
            MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        stem(Lue_bj,Rue_bj/sqrt(Ree_bj(M+1)*Ruu(M+1)),'or', ...
            MarkerSize=Mksize, MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir + "\"+analysisName + "\valid_correlation_BJ_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le BJ (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% Time data figure
        fig = figure; hold on;
        plot(t, y, 'k',LineWidth=1.4,DisplayName="Donn\'{e}es");
        plot(t, y_oe, "-r",LineWidth=2,DisplayName='Mod\`{e}le OE');
        plot(t, y_arx, "--g",LineWidth=2,DisplayName='Mod\`{e}le ARX');
        plot(t, y_armax, "-.b",LineWidth=2,DisplayName='Mod\`{e}le ARMAX');
        plot(t, y_bj, ":y",LineWidth=2, DisplayName='Mod\`{e}le BJ');
        grid minor; 
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
        legend(Location='southeast', Interpreter='latex', FontSize=17);
        saveas(fig, figDir + "\" + analysisName + "\comp_temps" ...
            + num2str(i) + ".eps", 'epsc');       

        if i == n_data
            msg = 'Press any key to continue...';
            input(msg);
            fprintf(repmat('\b', 1, length(msg)+1));
        end

        % Close all figures
        close all;
    end

    % Résultats (a être implanté)
    resid = NaN;

end