%% Entrées et définitions
dirInputName = 'newData';
dirOutputName = 'convertedData';
sysInfo; % Prendre les variables refatives aux systèmes

%% Main

dirFileNames = dir(dirInputName+"\*.xlsx");

for i = 1:length(sysData)  % Cherche chaque système
    expData = iddata(); % Crée an iddata vide

    % Cherche dans le dossier
    for j = 1:length(dirFileNames) 

        nameDivided = split(dirFileNames(j).name, '_');        
        if strcmp(sysData(i).name, nameDivided{1} + "_" + nameDivided{2})
            
            warning off; 
            dataRead = readtable(dirFileNames(j).folder + "\" + ...
                dirFileNames(j).name); 
            warning on;

            dataRead.y__C_ = dataRead.y__C_ - dataRead.y__C_(1);

            dataRead.u_V_ = (dataRead.u_V_/(sysData(i).R+sysData(i).R_))...
                .^2 * sysData(i).R / (pi * sysData(i).r^2);

            Ts = mean(dataRead.Temps(2:end) - dataRead.Temps(1:end-1));
            dataExp = iddata(dataRead.y__C_, dataRead.u_V_, Ts);
            
            % Autres informations
            dataExp.Name = sysData(i).name;
            dataExp.OutputName = 'Température';
            dataExp.OutputUnit = '°C';
            dataExp.InputName = 'Flux de chaleur';
            dataExp.InputUnit = 'W/m²';
            dataExp.TimeUnit = 'milliseconds';
            dataExp.ExperimentName = nameDivided{3}(1:4);
            dataExp.Tstart = 0;

            % Save
            if j == 1
                expData = dataExp;
            else
                expData = merge(expData, dataExp);
            end
        end        
    end
    
    % Enregistre tous les experiments réalisés
    save(dirOutputName + "\" +sysData(i).name, "expData");
end

