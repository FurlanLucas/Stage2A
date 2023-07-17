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

    %% Main
   
    figTemps = figure; % Création de la Figure du temps
    figCorr = figure; % Création de la Figure des correlations
    
    % Données de validation;
    for i = 1:n_data
        validData = getexp(dataIn, i);
        validData.y = validData.y;
        Ruu = xcorr(validData.u);
        
        % Modèle OE
        y_oe = lsim(sysOE, validData.u);
        e_oe = validData.y - y_oe;
        Ree_oe = xcorr(e_oe);
        Rue_oe = xcorr(e_oe, validData.u);
    
        % Modèle ARX
        y_arx = lsim(sysARX, validData.u);
        e_arx = validData.y - y_arx;
        noiseModel = idpoly(1,sysARX.A,1,1,1,sysARX.NoiseVariance,sysARX.Ts);
        e_arx = lsim(noiseModel, e_arx);
        Ree_arx = xcorr(e_arx);
        Rue_arx = xcorr(e_arx, validData.u);
    
        % Modèle ARMAX
        y_armax = lsim(sysARMAX, validData.u);
        e_armax = validData.y - y_armax;
        noiseModel = idpoly(1,sysARMAX.A,1,1,sysARMAX.C, ...
            sysARMAX.NoiseVariance,sysARMAX.Ts);
        e_armax = lsim(noiseModel, e_armax);
        Ree_armax = xcorr(e_armax);
        Rue_armax = xcorr(e_armax, validData.u);

        % Modèle BJ
        y_bj = lsim(sysBJ, validData.u);
        e_bj = validData.y - y_bj;
        noiseModel = idpoly(sysBJ.C,sysBJ.D,1,1,1, ...
            sysBJ.NoiseVariance, sysBJ.Ts);
        e_bj = lsim(noiseModel, e_bj);
        Ree_bj = xcorr(e_bj);
        Rue_bj = xcorr(e_bj, validData.u);
    
        % Figure des données (temps)
        figure(figTemps.Number);
        subplot(n_data, 1, i); hold on;
        plot(validData.SamplingInstants/60e3, validData.y, 'k', ...
            LineWidth=1.4, DisplayName="Donn\'{e}es");
        plot(validData.SamplingInstants/60e3, y_oe, "--r", LineWidth=1.4, ...
            DisplayName='Mod\`{e}le OE');
        plot(validData.SamplingInstants/60e3, y_arx, "-.g", LineWidth=1.4, ...
            DisplayName='Mod\`{e}le ARX');
        plot(validData.SamplingInstants/60e3, y_armax, "-.b", ...
            LineWidth=1.4, DisplayName='Mod\`{e}le ARMAX');
        plot(validData.SamplingInstants/60e3, y_bj, ":y", ...
            LineWidth=1.4, DisplayName='Mod\`{e}le ARMAX');
        grid minor; 
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
    
        % Figure des autocorrelations
        figure(figCorr.Number);
        subplot(n_data, 2, i*2-1); hold on; grid minor
        plot(Ree_oe/Ree_oe(length(e_oe)), 'or', MarkerSize=1);
        plot(Ree_arx/Ree_arx(length(e_arx)), 'og', MarkerSize=1);
        plot(Ree_armax/Ree_armax(length(e_armax)), 'ob', MarkerSize=1);
        plot(Ree_bj/Ree_bj(length(e_bj)), 'oy', MarkerSize=1);
        patch([xlim fliplr(xlim)], 2.17*[1 1 -1 -1]/sqrt(length(e_oe)), ...
            'black','FaceColor', 'black', 'FaceAlpha', 0.1);
        ylabel("Data "+num2str(i), Interpreter='latex', FontSize=17);
    
        % Figure des intercorrelations
        subplot(n_data, 2, i*2); hold on; grid minor;
        plot(Rue_arx/(Ree_arx(length(e_arx))*Ruu(length(e_arx))), 'og', ...
            MarkerSize=1, DisplayName="Mod\`{e}le ARMAX", MarkerFaceColor='g');
        plot(Rue_armax/(Ree_armax(length(e_armax))*Ruu(length(e_armax))), 'ob', ...
            MarkerSize=1, DisplayName="Mod\`{e}le ARX", MarkerFaceColor='b');
        plot(Rue_oe/(Ree_oe(length(e_oe))*Ruu(length(e_oe))), 'or', ...
            MarkerSize=1, DisplayName="Mod\`{e}le OE", MarkerFaceColor='r');
        plot(Rue_bj/(Ree_bj(length(e_bj))*Ruu(length(e_bj))), 'or', ...
            MarkerSize=1, DisplayName="Mod\`{e}le BJ", MarkerFaceColor='r');
        patch([xlim fliplr(xlim)], 2.17*[1 1 -1 -1]/sqrt(length(e_oe)), ...
            'black', 'FaceColor', 'black', 'FaceAlpha', 0.1, 'HandleVisibility', 'off');
        ylim(min(4*2.17/sqrt(length(e_oe)), 1)*[-1, 1]);
    end
    
    % Figure - configurations graphiques finales
    hold off;
    xlabel("Intercorr\'{e}lation $R_{ue}$", Interpreter='latex', FontSize=17);
    [~,objh] = legend(Interpreter="latex", FontSize=12, Location="northwest");
    objhl = findobj(objh, 'type', 'line'); %// objects of legend of type line
    set(objhl, 'Markersize', 10); %// set marker size as desired
    subplot(n_data, 2, i*2-1);
    xlabel("Autocorr\'{e}lation $R_{ee}$", Interpreter='latex', FontSize=17);
    figCorr.Position = [389 32 751 652];
    saveas(figCorr, figDir+"\"+analysisName+"\corr.eps");
    sgtitle({"Residues pour les donn\'{e}es", "de validation"}, ...
        Interpreter="latex", FontSize=20);
    figure(figTemps.Number);
    xlabel('Temps (min)', Interpreter='latex', FontSize=17);
    legend(Interpreter="latex", FontSize=12, Location="northwest");
    saveas(figTemps, figDir+"\"+analysisName+"\valid_poly.eps");
    sgtitle({"Donn\'{e}es de validation pour le", "mod\'{e}le OE "}, ...
        Interpreter="latex", FontSize=20);

    % Resultats
    resid = NaN;
end