function root = bissec(f, a, b, varargin)
    %% Bissec 
    % Fonction pour calculer la racine d'une équation avec le méthode de la 
    % bissection. Il prendre comme entrées la fontion f a être analysée et
    % les extrêmes d'intervale dans lequelle il y a la racine.
    %
    % Example d'appell :
    %
    % f = @(x) x^2 - 4;
    % ans = bissec(f, 0, 3); % Il va avoir une valeur de 2
    % ans = bissec(f, -3, 0); % Il va avoir une valeur de -2 
    %
    % Il y a aussi les arguments optionnels, à savoir :
    %
    %   - printProcess : Contrôle si il va avoir d'affichage de chaque
    %   iteration à l'écran ;
    %   - maxError : Contrôle de l'erreur minimale pour avoir la 
    %   convergence. Cet erreur sera donné par rapport a difference entre 
    %   x_k et x_k+1 en module.
    %   - maxIt : Contrôle  de le nombre d'iterations maximale pour avoir
    %   la convergence.

    %% Entrées
    % Valeur par défaut
    maxError = 1e-10; maxIt = 100; printProcess = false;

    % Test les argument optionelles
    for i=1:2:length(varargin)
        % Valeur d'erreur maximale par défaut (entre la différence de x)
        if varargin{i} == "error"
            maxError = varargin{i+1};
        end
        % Nombre de iteration maximale
        if varargin{i} == "maxIt"
            maxIt = varargin{i+1};
        end
        % Affiche chaque iteration
        if varargin{i} == "printProcess"
            printProcess = varargin{i+1};
        end
    end

    %% Poucle principale
    if printProcess
        disp('------------------------------------------');
        fprintf("It \t\t a \t\t b \t\t f(a) \t\t f(b)\n");
    end

    actualError = Inf; i = 0; oldMiddle = Inf;
    while (actualError > maxError) && (i < maxIt)
        newMiddle = (a+b)/2;
        if (f(a)*f(newMiddle)) < 0
            b = newMiddle;
        elseif (f(b)*f(newMiddle)) < 0
            a = newMiddle;
        elseif f(newMiddle) == 0
            root = newMiddle;
            if printProcess
                disp('------------------------------------------');
                fprintf("\nRacine trouvé à %d iteration. Error nule", i);
            end
            return 
        else
            fprintf("Impossible de trouver la racine (i = %d).\n\n",i);            
            return
        end

        if printProcess
            fprintf("[%2d] %5.2f \t %5.2f \t %5.2f \t %5.2f\n", i, a, ...
                b, f(a), f(b));
        end

        
        actualError = abs(newMiddle-oldMiddle);
        i = i + 1;
        oldMiddle = newMiddle; 
    end

    %% Ending
    root = newMiddle;
    if printProcess
        disp('------------------------------------------');
        fprintf("\nRacine trouvé à %d iteration\n", i);
    end

end