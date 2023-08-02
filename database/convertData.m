function convertData()
    %% convertData
    %
    %   Convert data
    %
    
    %% Entrées et définitions
    dirInputName = 'rawData'; % Dossier avec les données reçu ;
    dirOutputName = 'convertedData'; % Dossier avec les données de sortie ;
    sysInfo; % Prendre les variables refatives aux systèmes ;
    samplesNorm = 100; % Nombre d'échantillons pour calculler la moyenne ;
    
    %% Main
    
    dirFileNames = dir(dirInputName + "\*.txt");

    for i = 1:length(sysData)  % Cherche chaque système
    
        % Cherche dans le dossier
        found_data = 0;         
        Notes = {};

        for j = 1:length(dirFileNames)

            nameDivided = split(dirFileNames(j).name, '_');        
            if strcmp(sysData(i).name, nameDivided{1}+"_"+nameDivided{2})
                found_data = found_data + 1;
    
                % Lit le fichier
                opts = delimitedTextImportOptions("Delimiter", '\t', ...
                    'VariableNames', {'t','y_arr','v','phi','y_avant'});
                dataRead = readtable(dirFileNames(j).folder + "\" + ...
                    dirFileNames(j).name, opts); 

                % Transforme le tableau en vecteur
                t = str2double(strrep(dataRead.t(4:end,1), ',', '.'));
                y_arr = str2double(strrep(dataRead.y_arr(4:end),',','.'));
                v = str2double(strrep(dataRead.v(4:end,1), ',', '.'));
                phi = str2double(strrep(dataRead.phi(4:end,1), ',', '.'));
                y_avant = str2double(strrep(dataRead.y_avant(4:end), ...
                    ',','.'));            
                
                % Transforme les mesures en variations des mesures
                Ts = mean(t(2:end) - t(1:end-1));
                y_arr = sysData(i).setOutputArr(y_arr -  ...
                    mean(y_arr(1:samplesNorm)) );
                y_avant = sysData(i).setOutputArr(y_avant -  ...
                    mean(y_avant(1:samplesNorm)) );
                newDataExp = iddata([y_arr, y_avant], ...
                    sysData(i).toFlux(phi), Ts);
                Notes{j} = v;       
                
                % Autres informations auxilières
                newDataExp.Name = sysData(i).name;
                newDataExp.OutputName = {'Température arrière', ...
                                         'Température avant'};
                newDataExp.OutputUnit = {'°C', '°C'};
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