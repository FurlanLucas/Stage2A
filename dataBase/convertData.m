%% Entrées et définitions
dirInputName = 'rawData';
dirOutputName = 'convertedData';
sysInfo; % Prendre les variables refatives aux systèmes

%% Main

dirFileNames = dir(dirInputName + "\*.txt");

for i = 1:length(sysData)  % Cherche chaque système
    expData = iddata(); % Crée an iddata vide

    % Cherche dans le dossier
    found_data = 0; 
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

            if strcmp(sysData(i).type, 'tension')
                dataExp = iddata(y, sysData(i).toFlux(v), Ts);
            else
                dataExp = iddata(y, sysData(i).toFlux(phi), Ts);
                dataExp.UserData = v;
            end            
            
            % Autres informations auxilières
            dataExp.Name = sysData(i).name;
            dataExp.OutputName = 'Température';
            dataExp.OutputUnit = '°C';
            dataExp.InputName = 'Flux de chaleur';
            dataExp.InputUnit = 'W/m²';
            dataExp.TimeUnit = 'milliseconds';
            dataExp.ExperimentName = nameDivided{3}(1:4);
            dataExp.Tstart = 0;
            dataExp.Notes = sysData(i);            

            % Enregistrement des données
            if found_data == 1
                expData = dataExp;
            else
                expData = merge(expData, dataExp);
            end
            
        end        
    end
    
    % Enregistre tous les experiments réalisés
    save(dirOutputName + "\" +sysData(i).name, "expData");
end

