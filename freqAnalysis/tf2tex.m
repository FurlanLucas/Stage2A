function tf2tex(tf, analysis, variable, name, factorPower)
    %% tf2tex
    %
    % Writes a transfer function in latex form. It is used to repport tex
    % files.
    %
    % Calls
    %
    %   tf2tex(tf, analysis, variable, name): creates a file named name.tex 
    %   in the tex files output directory with the expression of the transfer
    %   function. The name of the transfer function is saved as name. A
    %   label is created with name. The analysis struct saves the output
    %   file name;
    %
    %   tf2tex(tf, analysis, variable, name): creates a file named name.tex 
    %   in the tex files output directory with the expression of the transfer
    %   function. The name of the transfer function is saved as name. A
    %   label is created with name and a factor of 10^factorPower is used 
    %   in the numerator. The denominator is displayed as itself.
    %
    % Inputs
    %
    %   tf: matlab transfer function variable to be written in tex file;
    %
    %   analysis: analysis settings;
    %
    %   variable: string with variable name to be created in the tex file;
    %
    %   name: name of the tex output file and the label for the equation;
    %
    %   factorPower: powerFactor to be applayed to the numerator, default
    %   value is 1.
    %
    % See also Contents, analysisSettings.

    %% Inputs
    dirOut = analysis.texDir;

    fileHandle = fopen(dirOut + "\" + name + ".tex", 'w');
    n_num = length(tf.Numerator{1});
    n_dem = length(tf.Denominator{1});
    var = tf.Variable;

    if ~exist('factorPower', 'var')
        factorPower = 0;
    end
    
    %% Continuous system
    
    if strcmp(var, 's')
        fprintf(fileHandle, variable + "(s) = \\frac{");
        for i = 1:n_num-1
            value = tf.Numerator{1}(i)*(10^factorPower);
            if abs(value) > 1e-4
                fprintf(fileHandle, " " + toStr(value,3,i~=1) + ...
                    "s^%d", n_dem-i);
            end
        end
        fprintf(fileHandle, " " + toStr(tf.Numerator{1}(end),3,true));    
        fprintf(fileHandle, "}{");    
        for i = 1:n_dem-1
            value = tf.Denominator{1}(i);
            if abs(value) > 1e-4
    
                fprintf(fileHandle, " " + toStr(value,3,i~=1) + ...
                    "s^%d", n_dem-i);
            end
        end
        fprintf(fileHandle, " + 1");
        if factorPower ~= 0
            fprintf(fileHandle, "}\\cdot 10^{%d}", -factorPower);
        else
            fprintf(fileHandle, "}");
        end
    end

        %% Discrete system
    
    if strcmp(var, 'z')
        fprintf(fileHandle, variable + "(z^{-1}) = \\frac{");
        for i = 1:n_num
            value = tf.Numerator{1}(i)*(10^factorPower);
            if i~=1
                fprintf(fileHandle, " " + toStr(value,3,true) + ...
                    "z^{-%d}", i-1);
            else
                fprintf(fileHandle, " " + toStr(value,3,false));
            end
        end  
        fprintf(fileHandle, "}{");    
        for i = 1:n_dem
            value = tf.Denominator{1}(i);
            if i~=1    
                fprintf(fileHandle, " " + toStr(value,3,true) + ...
                    "z^{-%d}", i-1);
            else
                fprintf(fileHandle, " 1");
            end
        end
        if factorPower ~= 0
            fprintf(fileHandle, "}\\cdot 10^{%d}", -factorPower);
        else
            fprintf(fileHandle, "}");
        end
    end

    % Ending    
    fclose(fileHandle);

end


function strOut = toStr(number, digit, plus)
    % Take the digit number of first digits of a number
    
    value = round(number, digit,'significant');
    if number == 1
        strOut = "1";
        return;
    elseif plus || number < 0 
        strOut = convertStringsToChars(sprintf("%+f", value));
    else
        strOut = convertStringsToChars(sprintf("%f", value));
    end

    for i = length(strOut):-1:1
        if strOut(i) ~= '0'
            break
        end
    end
    strOut = convertCharsToStrings(strOut(1:i));
end
