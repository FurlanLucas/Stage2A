function tf2tex(tf, variable, name)
    %% tf2tex
    %
    % Writes a transfer function in 

    %% Inputs
    dirOut = 'texOut';

    fileHandle = fopen(dirOut + "\" + name + ".tex", 'w');
    n_num = length(tf.Numerator{1});
    n_dem = length(tf.Denominator{1});
    var = tf.Variable;

    %% Main
    
    fprintf(fileHandle, "\\begin{equation*}\n\t" +variable+ " = \\frac{");
    for i = 1:n_num-1
        value = tf.Numerator{1}(i);
        if abs(value) > 1e-4
            fprintf(fileHandle, " " + toStr(value,3,i~=1) + var + "^%d", ...
                n_dem-i);
        end
    end
    fprintf(fileHandle, " " + toStr(tf.Numerator{1}(end),3,true));

    fprintf(fileHandle, "}\n\t{");

    for i = 1:n_dem-1
        value = tf.Denominator{1}(i);
        if abs(value) > 1e-4

            fprintf(fileHandle, " " + toStr(value,3,i~=1) + var + "^%d", ...
                n_dem-i);
        end
    end
    fprintf(fileHandle, " " + toStr(tf.Numerator{1}(end),3,true));

    fprintf(fileHandle, "}\n\\end{equation*}");

    % Ending    
    fclose(fileHandle);

end


function strOut = toStr(number, digit, plus)
    value = round(number, digit,'significant');
    if plus
        strOut = sprintf("+%g", value);
    else
        strOut = sprintf("%g", value);
    end
end
