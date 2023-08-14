function root = bissec(f, a, b, varargin)
    %% bissec
    %
    % Bissection method implementation to find a root of a function.
    % Receives a handle to the function and the values of the interval [a,
    % b] such that f(a)*f(b) < 0. Will find a unique root. A sample mean
    % value is calculated in each iteration.
    %
    % Call
    %
    %   root = bissec(f, a, b): find a root of the function f in the
    %   interval [a, b]. If there is more than one root, it will return
    %   only one of them.
    %
    %   root = bissec(__, options): give aditional options to the call.
    %
    % Inputs
    %
    %   f: funtion handle;
    %
    %   a: double giving the beginning of the interval;
    %
    %   b: double giving the ending of the interval.
    %
    % Outputs
    %
    %   root: output root for the bissection method;
    %
    % Aditional options
    %
    %   printProcess: controls if the function will display each iteration
    %   at the command window. The default value is false;
    %
    %   relErro: minimal error to consider the method convergent. The error
    %   is relative to the prior iteration e(k) = x(k) - x(k-1). The default
    %   is 1e-10;
    %
    %   maxIt: controls the maximum iteration fot the method. The default
    %   value is 100;

    %% Inputs
    % Default values
    relError = 1e-10; maxIt = 100; printProcess = false;

    % Optional arguments
    for i=1:2:length(varargin)        
        switch varargin{i}
            % Minimum relative error
            case 'relError'
                relError = varargin{i+1};

            % Maximum iteration
            case 'maxIt'      
                maxIt = varargin{i+1};

            % Display the iterations
            case 'printProcess'     
                printProcess = varargin{i+1};

            % Error
            otherwise
                error("The option << " + varargin{i} + " >> is invalid.");
        end
    end

    %% Boucle principale
    if printProcess
        disp('------------------------------------------');
        fprintf("It \t\t a \t\t b \t\t f(a) \t\t f(b)\n");
    end

    actualError = Inf; i = 0; oldMiddle = Inf;
    while (actualError > relError) && (i < maxIt)
        newMiddle = (a+b)/2;
        if (f(a)*f(newMiddle)) < 0
            b = newMiddle;
        elseif (f(b)*f(newMiddle)) < 0
            a = newMiddle;
        elseif f(newMiddle) == 0
            root = newMiddle;
            if printProcess
                disp('------------------------------------------');
                fprintf("\nRoot find at %d iteration without error", i);
            end
            return 
        else
            fprintf("Impossible to find the root (i = %d).\n\n",i);            
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
        fprintf("\nRoot find at %d iteration.\n", i);
    end

end