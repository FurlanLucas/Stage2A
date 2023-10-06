function prec2table(sysData, analysis, h, orders, type)
    %% prec2table
    %
    % Compute the precision in rad/s for each polynomial approximation and
    % builds a table in tex style.

    %% Inputs
    texDir = analysis.texDir;    
    
    maxMag = 3;
    maxPhase = 15;

    % Check type
    if ~exist('type', 'var')
        type = 1;
    end

    % Simulation
    results_1d_th = model_1d(sysData, h); % Theoretical result


    %% Main

    if type == 1
        fileHandle = fopen(texDir + "\precTableFlux.tex", "w");
    else
        fileHandle = fopen(texDir + "\precTableTemp.tex", "w");
    end
    
    % Table
    fprintf(fileHandle, "\\begin{table}" + ...
        "[H]\n\\centering\n\\begin{tabular}{ccccc}\n" + ...
        "\t\\hline\n\t\\multirow{2}{*}{Order}\t&\t\\multicolumn{2}{c}" + ...
        "{\\makecell{Max mag \\\\ of 3dB (rad/s)}}\t&\t\\multicolumn{2}" + ...
        "{c}{\\makecell{Max phase \\\\ of $15^\\circ$ (rad/s)}} \\\\\n\t" + ...
        "\\cline{2-5}\n\t&\tTaylor\t&\tPadé\t&\tTaylor\t&\tPadé\\\\" + ...
        "\n\t\\hline\n");

    for i=1:length(orders)

        results_taylor = model_1d_taylor(sysData, h, orders(i));
        results_pade = model_1d_pade(sysData, h, orders(i));

        % Pade
        magPade = abs(mag2db(results_pade.mag{type}) - ...
            mag2db(results_1d_th.mag{type}));
        phasePade = abs((results_pade.phase{type} - ...
            results_1d_th.phase{type})*180/pi);
        wMagPade = results_pade.w(find(magPade>maxMag, 1));
        wPhasePade = results_pade.w(find( ...
            (phasePade - 360*(phasePade>300))>maxPhase, 1));

        % Taylor
        magTaylor = abs(mag2db(results_taylor.mag{type}) - ...
            mag2db(results_1d_th.mag{type}));
        phaseTaylor = abs((results_taylor.phase{type} - ...
            results_1d_th.phase{type})*180/pi);
        wMagTaylor = results_taylor.w(find(magTaylor>maxMag, 1));
        wPhaseTaylor = results_taylor.w(find( ...
            (phaseTaylor - 360*(phaseTaylor>300))>maxPhase, 1));


        fprintf(fileHandle, "\t$%d$\t&", orders(i));
        % Mag
        if wMagTaylor<=wPhaseTaylor
            fprintf(fileHandle, "\\cellcolor{red!25}\t$%.4f$\t&", wMagTaylor);
        else
            fprintf(fileHandle, "\t$%.4f$\t&", wMagTaylor);
        end
        if wMagPade<=wPhasePade
            fprintf(fileHandle, "\\cellcolor{red!25}\t$%.4f$\t&", wMagPade);
        else
            fprintf(fileHandle, "\t$%.4f$\t&", wMagPade);
        end

        % Phase
        if wMagTaylor>wPhaseTaylor
            fprintf(fileHandle, "\\cellcolor{red!25}\t$%.4f$\t&", wPhaseTaylor);
        else
            fprintf(fileHandle, "\t$%.4f$\t&", wPhaseTaylor);
        end
        if wMagPade>wPhasePade
            fprintf(fileHandle, "\\cellcolor{red!25}\t$%.4f$ \\\\\n", wPhasePade);
        else
            fprintf(fileHandle, "\t$%.4f$ \\\\\n", wPhasePade);
        end
        
    end

    %% Ending

    if type==1
        fprintf(fileHandle, "\t\\hline\n\\end{tabular}\n\\caption{" + ...
            "Precision in polynomial approximation for heat flux" + ...
            " transfer function $\\tilde{G}_\\varphi(s)$. Red cells" + ...
            " indicate the frequency limit." + ...
            "}\n\\label{tab:precision_1d_flux}\n\\end{table}");
    else
        fprintf(fileHandle, "\t\\hline\n\\end{tabular}\n\\caption{" + ...
            "Precision in polynomial approximation for temperature" + ...
            " transfer function $\\tilde{G}_\\theta(s)$. Red cells" + ...
            " indicate the frequency limit." + ...
            "}\n\\label{tab:precision_1d_flux}\n\\end{table}");
    end

    fclose(fileHandle);

end
    