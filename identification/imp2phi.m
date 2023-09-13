function u = imp2phi(ym,h,r,Ts)
    %% imp2phi
    %
    % Sequential estimation of the input u from the impulse response
    % calculated for each sensor. The method uses the future time steps 
    % algorithm with constant specification function.
    % The algorithme is described in the book of: Beck J., Blackwell B., 
    % St. Clair C.R., Inverse Heat Conduction, A Wiley-Interscience Publication, 
    % 1985.

    %% Inputs

    % Prealocating
    N = length(ym);
    u = zeros(N,1);
    phi = zeros(r,1);
   
    % Step response
    for m = 1:r
        phi(m) = 0;
        for i = 1:m
            phi(m) = phi(m)+Ts*h(i);
        end
    end

    %% Main

    % Donominator
    den = 0; 
    for m = 1:r
        den = den+phi(m)^2;
    end

    % Main
    for k = 1:N-r
       num = 0;
       T_tilde = zeros(r,1);
       for m = 1:r
         T_tilde(m) = 0; 
         for i = 1:(k-1)
            T_tilde(m) = T_tilde(m)+Ts*h(k-i+m)*u(i);
         end
         num = num+(ym(k+m-1)-T_tilde(m))*phi(m);
       end
       u(k) = num/den;
    end

end