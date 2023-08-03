function convertData()
    %% convertData
    %
    %   Convert data
    %
    
    %% Entrées et définitions
    dirInputName = 'rawData'; % Dossier avec les données reçu ;
    dirOutputName = 'convertedData'; % Dossier avec les données de sortie ;
    sysInfo; % Prendre les variables refatives aux systèmes ;
    
    %% Main
    
    allFileNames = {dir(dirInputName + "\*.txt").name};

    for i = 1:length(sysData)  % Cherche chaque système
    
        % Crée le variable de donnée thermalData
        expData = thermalData(sysData(i));

        % Cherche dans le dossier
        pos = contains(allFileNames, sysData(i).name);
        fileNames = {allFileNames{pos}};
        n_files = sum(pos)-1;

        % Par chaque fichier
        for j = 1:n_files
    
            % Lit le fichier
            opts = delimitedTextImportOptions("Delimiter", '\t', ...
                'VariableNames', {'t','y_back','v','phi','y_front'});
            dataRead = readtable(dirInputName + "\" + fileNames{j}, opts); 

            % Transforme le tableau en vecteur
            t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
            y_back = str2double(strrep(dataRead.y_back(4:end),',','.'));
            v = str2double(strrep(dataRead.v(4:end,1), ',', '.'));
            phi = str2double(strrep(dataRead.phi(4:end,1), ',', '.'));
            y_front = str2double(strrep(dataRead.y_front(4:end), ',','.'));            
            
            % Transforme les mesures en variations des mesures
            y_front = sysData(i).setOutputArr(toVar(y_front));
            y_back = sysData(i).setOutputArr(toVar(y_back));
            phi = sysData(i).toFlux(toVar(phi));       
            
            % Autres informations auxilières
            expData.y_front{j} = y_front;
            expData.y_back{j} = y_back;
            expData.v{j} = v;
            expData.phi{j} = phi;
            expData.t{j} = t;
            
        end   
        
        % Enregistre tous les experiments réalisés
        save(dirOutputName + "\" +sysData(i).name, "expData");
    end

end