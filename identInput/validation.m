function resid = validation(dataIn, models, varargin)
    %% VALIDATION
    %
    % Il fait la validation des models identifiés en models avec les 
    % données disponible en dataIn. La validation des données seront faite
    % avec la autocorrélation d'erreur d'équation et aussi avec
    % l'intercorrélation entre l'erreur d'équation et l'entrée de flux de
    % chaleur.
    %
    % EXAMPLE D'APPELL :
    %
    %   validation(dataIn, models) : pour analyser les données experimental
    %   dedans dataIn. dataIn doit être une variable du type iddata avec un
    %   champs UserData comme sysDataType.
    %
    %   compare_results(__, options) : pour données des autres options à
    %   l'analyse.
    %
    % EENTRÉES :
    % 
    %   - dataIn : variable iddata avec l'entrée qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs UserData dedans dataIn. Il sera estoqué comme sysDataType.
    %
    %   models : modèles identifiés dans l'analyse de convergence. Il doit
    %   être une variable du type struct avec un champ par chaque modèle
    %   identifié. Donc :
    %       models.ARX : modèle ARX identifié.
    %       models.OE : modèle AOE identifié.
    %       models.ARMAX : modèle ARMAX identifié.
    %       models.BJ : modèle BJ identifié.
    %
    % OPTIONS :
    %
    %   setExp : Configure les experiments qui doivent être analysé. Le
    %   résultat obtenu avec validation(dataIn, models, setExp=[1,2]) est
    %   le même que avec validation(getexp(dataIn, [1,2]), models).
    %
    % See compare_results, iddata, sysDataType.

    %% Entrées fixes et entrée par défauts 

    figDir = 'outFig';        % [-] Emplacement pour les figures générées ;
    analysisName = dataIn.UserData.name; % [-] Non de l'analyse ; 
    M = 20;                              %
    prob = 5.5758;


    %% Prendre les entrées optionnelles
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("setExp")
                    dataIn = getexp(dataIn, varargin{arg, 2});
                    break;
                case ("M")
                    M = varargin{arg, 2};
                    break;
            end
        end
    end

    %% Partie principal

    n_data = size(dataIn, 4); % Numéro des analyses de validation
    sysARX = models.ARX;
    sysOE= models.OE;
    sysARMAX = models.ARMAX;
    sysBJ = models.BJ;    
   
    figTemps = figure; % Création de la Figure du temps    

    % Données de validation;
    for i = 1:n_data
        fprintf("\t\tAnalyse pour le jeux %s.\n",dataIn.ExperimentName{i});
        validData = getexp(dataIn, i);
        t = validData.SamplingInstants/60e3; % Temps en minutes
        y = validData.y; % Vrai sortie (mesurée)
        N = length(validData.y);

        % Corrrélation d'entrée
        Ruu = xcorr(validData.u, M, 'biased');
        
        %% Modèle OE
        y_oe = lsim(sysOE, validData.u);
        e_oe = validData.y - y_oe;
        [Ree_oe, Lee_oe] = xcorr(e_oe, M, 'biased');
        [Rue_oe, Lue_oe] = xcorr(e_oe, validData.u, M, 'biased');
        P1_oe = abs(Ruu' * Ree_oe);

        % Régions de confiances
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_oe)/sqrt(Ree_oe(M+1)*Ruu(M+1)*N);

        % Figure des correlations (modèle OE)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        plot(Lee_oe, Ree_oe/Ree_oe(M+1), 'or', MarkerSize=1);
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        plot(Lue_oe, Rue_oe/sqrt(Ree_oe(M+1)*Ruu(M+1)),'or',MarkerSize=1);
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName + "\valid_correlation_OE_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le OE (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% Modèle ARX
        y_arx = lsim(sysARX, validData.u);
        e_arx = validData.y - y_arx;
        noiseModel = idpoly(1,sysARX.A,1,1,1,sysARX.NoiseVariance,sysARX.Ts);
        e_arx = lsim(noiseModel, e_arx);
        [Ree_arx, Lee_arx] = xcorr(e_arx, M, 'biased');
        [Rue_arx, Lue_arx] = xcorr(e_arx, validData.u, M, 'biased');
        P1_arx = abs(Ruu' * Ree_arx);

        % Régions de confiances
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_arx)/sqrt(Ree_arx(M+1)*Ruu(M+1)*N);

        % Figure des correlations (modèle ARX)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        plot(Lee_arx, Ree_arx/Ree_arx(M+1), 'or', MarkerSize=1);
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        plot(Lue_arx, Rue_arx/sqrt(Ree_arx(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=1);
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName + "\valid_correlation_ARX_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% Modèle ARMAX
        y_armax = lsim(sysARMAX, validData.u);
        e_armax = validData.y - y_armax;
        noiseModel = idpoly(1,sysARMAX.A,1,1,sysARMAX.C, ...
            sysARMAX.NoiseVariance,sysARMAX.Ts);
        e_armax = lsim(noiseModel, e_armax);
        [Ree_armax, Lee_armax] = xcorr(e_armax, M, 'biased');
        [Rue_armax, Lue_armax] = xcorr(e_armax, validData.u, M, 'biased');
        P1_armax = abs(Ruu' * Ree_armax);

        % Régions de confiances
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_armax)/sqrt(Ree_armax(M+1)*Ruu(M+1)*N);

        % Figure des correlations (modèle ARMAX)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        plot(Lee_armax, Ree_armax/Ree_armax(M+1), 'or', MarkerSize=1);
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        plot(Lue_armax, Rue_armax/sqrt(Ree_armax(M+1)*Ruu(M+1)), 'or', ...
            MarkerSize=1);
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir+"\"+analysisName +"\valid_correlation_ARMAX_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le ARMAX (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);

        %% Modèle BJ
        y_bj = lsim(sysBJ, validData.u);
        e_bj = validData.y - y_bj;
        noiseModel = idpoly(sysBJ.C,sysBJ.D,1,1,1, ...
            sysBJ.NoiseVariance, sysBJ.Ts);
        e_bj = lsim(noiseModel, e_bj);
        [Ree_bj, Lee_bj] = xcorr(e_bj, M, 'biased');
        [Rue_bj, Lue_bj] = xcorr(e_bj, validData.u, M, 'biased');
        P1_bj = abs(Ruu' * Ree_bj);

        % Régions de confiances
        confRauto = prob/sqrt(N);
        confRinter = prob*sqrt(P1_bj/(Ree_bj(M+1)*Ruu(M+1)*N));

        % Figure des correlations (modèle BJ)
        fig = figure;
        subplot(1, 2, 1); hold on; grid minor;
        plot(Lee_bj, Ree_bj/Ree_bj(M+1), 'or', MarkerSize=1);
        patch([xlim fliplr(xlim)], confRauto*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        ylabel("Amplitude", Interpreter='latex', FontSize=17);
        title("Autocorr\'{e}lation $R_{\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        hold off; subplot(1, 2, 2); hold on; grid minor;
        plot(Lue_bj,Rue_bj/sqrt(Ree_bj(M+1)*Ruu(M+1)),'or',MarkerSize=1);
        patch([xlim fliplr(xlim)], confRinter*[1 1 -1 -1], 'black', ...
            FaceColor='black', FaceAlpha=0.1, EdgeColor='none');
        title("Intercorr\'{e}lation $R_{u\epsilon}$", ...
            Interpreter='latex', FontSize=17);
        saveas(fig, figDir + "\"+analysisName + "\valid_correlation_BJ_"...
            + num2str(i) + ".eps", 'epsc');
        sgtitle("Mod\'{e}le BJ (jeux " + num2str(i) + ")", ...
            Interpreter='latex', FontSize=23);
    
        %% Figure des données (temps)
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

        % Ferme les figures
        close all;
    end

    % Résultats (a être implanté)
    resid = NaN;

end