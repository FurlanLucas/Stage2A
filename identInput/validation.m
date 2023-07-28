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

    %% Entrées

    figDir = 'outFig';        % [-] Emplacement pour les figures générées ;
    analysisName = dataIn.UserData.name; % [-] Non de l'analyse ; 

    % Prendre les entrées optionnelles
    if ~isempty(varargin)
        for arg = 1:length(varargin)
            switch varargin{arg,1}
                case ("setExp")
                    dataIn = getexp(dataIn, varargin{arg, 2});
                    break;
            end
        end
    end

    % Modèles identifiées
    n_data = size(dataIn, 4); % Numéro des analyses de validation
    sysARX = models.ARX;
    sysOE= models.OE;
    sysARMAX = models.ARMAX;
    sysBJ = models.BJ;    

    %% Main figure (general comparaison)
   
    figTemps = figure; % Création de la Figure du temps
    figCorr = figure; % Création de la Figure des correlations
    
    % Données de validation;
    for i = 1:n_data
        validData = getexp(dataIn, i);
        t = validData.SamplingInstants/60e3; % Temps en minutes
        y = validData.y; % Vrai sortie (mesurée)

        % Régions de confiances
        confR = 1.96/sqrt(length(validData.y));
        
        % Modèle OE
        y_oe = lsim(sysOE, validData.u);
        e_oe = validData.y - y_oe;
        [Ree_oe, Lee_oe] = xcorr(e_oe, 'coeff');
        [Rue_oe, Lue_oe] = xcorr(e_oe, validData.u, 'coeff');
    
        % Modèle ARX
        y_arx = lsim(sysARX, validData.u);
        e_arx = validData.y - y_arx;
        noiseModel = idpoly(1,sysARX.A,1,1,1,sysARX.NoiseVariance,sysARX.Ts);
        e_arx = lsim(noiseModel, e_arx);
        [Ree_arx, Lee_arx] = xcorr(e_arx, 'coeff');
        [Rue_arx, Lue_arx] = xcorr(e_arx, validData.u, 'coeff');
    
        % Modèle ARMAX
        y_armax = lsim(sysARMAX, validData.u);
        e_armax = validData.y - y_armax;
        noiseModel = idpoly(1,sysARMAX.A,1,1,sysARMAX.C, ...
            sysARMAX.NoiseVariance,sysARMAX.Ts);
        e_armax = lsim(noiseModel, e_armax);
        [Ree_armax, Lee_armax] = xcorr(e_armax, 'coeff');
        [Rue_armax, Lue_armax] = xcorr(e_armax, validData.u, 'coeff');

        % Modèle BJ
        y_bj = lsim(sysBJ, validData.u);
        e_bj = validData.y - y_bj;
        noiseModel = idpoly(sysBJ.C,sysBJ.D,1,1,1, ...
            sysBJ.NoiseVariance, sysBJ.Ts);
        e_bj = lsim(noiseModel, e_bj);
        [Ree_bj, Lee_bj] = xcorr(e_bj, 'coeff');
        [Rue_bj, Lue_bj] = xcorr(e_bj, validData.u, 'coeff');
    
        % Figure des données (temps)
        figure(figTemps.Number);
        subplot(n_data, 1, i); hold on;
        plot(t, y, 'k',LineWidth=1.4,DisplayName="Donn\'{e}es");
        plot(t, y_oe, "-r",LineWidth=2,DisplayName='Mod\`{e}le OE');
        plot(t, y_arx, "-.g",LineWidth=2,DisplayName='Mod\`{e}le ARX');
        plot(t, y_armax, "-.b",LineWidth=2,DisplayName='Mod\`{e}le ARMAX');
        plot(t, y_bj, ":y",LineWidth=2, DisplayName='Mod\`{e}le BJ');
        grid minor; 
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
    
        % Figure des autocorrelations
        figure(figCorr.Number);
        subplot(n_data, 2, i*2-1); hold on; grid minor
        plot(Lee_oe, Ree_oe, 'or', MarkerSize=1);
        plot(Lee_arx, Ree_arx, 'og', MarkerSize=1);
        plot(Lee_armax, Ree_armax, 'ob', MarkerSize=1);
        plot(Lee_bj, Ree_bj, 'oy', MarkerSize=1);
        patch([xlim fliplr(xlim)], confR*[1 1 -1 -1], 'black', ...
            'FaceColor', 'black', 'FaceAlpha', 0.1);
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
    
        % Figure des intercorrelations
        subplot(n_data, 2, i*2); hold on; grid minor;
        plot(Lue_oe, Rue_oe, 'or', MarkerSize=1, ...
            DisplayName="Mod\`{e}le OE", MarkerFaceColor='r');
        plot(Lue_armax, Rue_armax, 'ob', MarkerSize=1, ...
            DisplayName="Mod\`{e}le ARX", MarkerFaceColor='b');
        plot(Lue_arx, Rue_arx, 'og', MarkerSize=1, MarkerFaceColor='g', ...
            DisplayName="Mod\`{e}le ARMAX");
        plot(Lue_bj, Rue_bj, 'oy', MarkerSize=1, ...
            DisplayName="Mod\`{e}le BJ", MarkerFaceColor='y');
        patch([xlim fliplr(xlim)], 2.17*[1 1 -1 -1]/sqrt(length(e_oe)), ...
            'black', 'FaceColor', 'black', 'FaceAlpha', 0.1, ...
            'HandleVisibility', 'off');
        ylim(max(4*2.17/sqrt(length(e_oe)), 1)*[-1, 1]);
    end
    
    % Figure - configurations graphiques finales
    hold off;
    xlabel("Intercorr\'{e}lation $R_{ue}$", Interpreter='latex', ...
        FontSize=17);
    [~,objh]=legend(Interpreter="latex",FontSize=12,Location="northwest");
    objhl = findobj(objh, 'type', 'line');
    set(objhl, 'Markersize', 10);
    subplot(n_data, 2, i*2-1);
    xlabel("Autocorr\'{e}lation $R_{ee}$",interpreter='latex',FontSize=17);
    figCorr.Position = [389 32 751 652];
    saveas(figCorr, figDir+"\"+analysisName+"\corr.eps");
    sgtitle({"Residues pour les donn\'{e}es", "de validation"}, ...
        Interpreter="latex", FontSize=20);
    figure(figTemps.Number);
    xlabel('Temps (min)', Interpreter='latex', FontSize=17);
    legend(Interpreter="latex", FontSize=12, Location="northwest");
    saveas(figTemps, figDir+"\"+analysisName+"\valid_poly.eps", 'epsc');
    sgtitle({"Donn\'{e}es de validation pour le", "mod\'{e}le OE "}, ...
        Interpreter="latex", FontSize=20);

    % Résultats (a être implanté)
    resid = NaN;

end