function phi = imp2phi(ym,g,r,Ts)
    %% imp2phi
    %
    % Sequential estimation of the input u from the impulse response
    % estimated by identification system's analysis. The method uses the 
    % future time steps algorithm with constant specification function.
    % The algorithme is described in the book of: Beck J., Blackwell B., 
    % St. Clair C.R., Inverse Heat Conduction, A Wiley-Interscience Publication, 
    % 1985. This code is a second version of a implementation by Prof.
    % Jean-Luc Battaglia, I2M, Bordeaux.
    %
    % Calls
    %
    %   phi = imp2phi(ym,h,r,Ts): calculate an estimative for heat flux
    %   from the impulse response.
    %
    % Inputs
    %
    %   ym: measured temperature (input data);
    %
    %   g: impulse response, have to have at least the same number of
    %   samplings that are in ym;
    %
    %   r: number of steps in the future to be minimized;
    %
    %   Ts: sampling time in seconds.
    %
    % Outputs
    %
    %   phi: estimated heat flux.
    %
    % See also impulseInverse, inversion.

    %% Inputs

    % Prealocating
    N = length(ym);
    phi = zeros(N,1);
    beta = zeros(r,1);
   
    % Step response
    for m = 1:r
        beta(m) = 0;
        for i = 1:m
            beta(m) = beta(m)+Ts*g(i);
        end
    end

    %% Main

    % Donominator
    den = 0; 
    for m = 1:r
        den = den+beta(m)^2;
    end

    % Main
    for k = 1:N-r
       num = 0;
       T_tilde = zeros(r,1);
       for m = 1:r
         T_tilde(m) = 0; 
         for i = 1:(k-1)
            T_tilde(m) = T_tilde(m)+Ts*g(k-i+m)*phi(i);
         end
         num = num+(ym(k+m-1)-T_tilde(m))*beta(m);
       end
       phi(k) = num/den;
    end

end