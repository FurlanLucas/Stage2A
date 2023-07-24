function convertData()
    %% convertData
    %
    %   Convert data
    %
    
    %% Entrées et définitions
    dirInputName = 'rawData';
    dirOutputName = 'convertedData';
    sysInfo; % Prendre les variables refatives aux systèmes
    
    %% Main
    
    dirFileNames = dir(dirInputName + "\*.txt");

    for i = 1:length(sysData)  % Cherche chaque système
    
        % Cherche dans le dossier
        found_data = 0; 
        Notes = {};
        for j = 1:length(dirFileNames)

            nameDivided = split(dirFileNames(j).name, '_');        
            if strcmp(sysData(i).name, nameDivided{1} + "_" + nameDivided{2})
                found_data = found_data + 1;
    
                % Lit le fichier
                opts = delimitedTextImportOptions("Delimiter", '\t', ...
                    'VariableNames', {'t', 'y', 'v', 'phi'});
                dataRead = readtable(dirFileNames(j).folder + "\" + ...
                    dirFileNames(j).name, opts); 
                t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
                y = str2double(strrep(dataRead.y(4:end), ',', '.'));
                v = str2double(strrep(dataRead.v(4:end,1), ',', '.'));
                phi = str2double(strrep(dataRead.phi(4:end,1), ',', '.'));            
                Ts = mean(t(2:end) - t(1:end-1));
                
                % Transforme la sortie en variation de la sortie
                y = sysData(i).setOutput(y - y(1));
    
                if strcmp(sysData(i).type, 'tension') % asasas
                    %newDataExp = iddata(sysData(i).toFlux(v), y, Ts);
                    newDataExp = iddata(y, sysData(i).toFlux(v), Ts);
                    Notes = [Notes, {'NULL'}];
                else
                    %newDataExp = iddata(sysData(i).toFlux(phi), y, Ts);
                    newDataExp = iddata(y, sysData(i).toFlux(phi), Ts);
                    Notes = [Notes, {v}];
                end            
                
                % Autres informations auxilières
                newDataExp.Name = sysData(i).name;
                newDataExp.OutputName = 'Température';
                newDataExp.OutputUnit = '°C';
                newDataExp.InputName = 'Flux de chaleur';
                newDataExp.InputUnit = 'W/m²';
                newDataExp.TimeUnit = 'milliseconds';
                newDataExp.ExperimentName = nameDivided{3}(1:4);
                newDataExp.Tstart = 0;       
    
                % Enregistrement des données
                if found_data == 1
                    expData = newDataExp;
                else
                    expData = merge(expData, newDataExp);
                end
                
            end        
        end
        
        % Enregistre tous les experiments réalisés
        expData.UserData = sysData(i); 
        expData.Notes = Notes;
        save(dirOutputName + "\" +sysData(i).name, "expData");
    end
    
    clear;
end