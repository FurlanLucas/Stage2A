function toFile(signal, name)
    %% toFile
    %
    % Write the signal variable to a file ooutput.

    %% Main

    fileHandle = fopen(name, 'w');

    for i = 1:length(signal)
        fprintf(fileHandle, "%f,\n", signal(i));
    end

    fclose(fileHandle);
end