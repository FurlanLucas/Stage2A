function dataOut = transformInput(dataIn)
    %% transformInput
    %
    % Prends le données et transforme en donnée d'entrée

    %% Main

    n_data = size(dataIn, 4);

    for i = 1:n_data
        curr_exp = getexp(dataIn, i);
        curr_data = iddata(curr_exp.u, dataIn.Notes{i}.^2);
        curr_data.Ts = curr_exp.Ts;
        curr_data.TimeUnit = dataIn.TimeUnit;

        if i == 1
            dataOut = curr_data;
        else
            dataOut = merge(dataOut, curr_data);
        end
    end

    % SysDataType
    dataOut.UserData = dataIn.UserData;
end