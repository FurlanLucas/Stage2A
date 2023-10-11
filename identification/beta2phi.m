function phi = beta2phi(ym, beta, r)
    %% beta2phi
    %
    %
    %

    %% Main

    % Prealocating
    N = length(ym);
    phi = zeros(N,1);

    %% Main

    % Donominator
    den = 0; 
    for k = 1:r
        den = den+beta(k)^2;
    end

    Dbeta = [beta(1); beta(2:end) - beta(1:end-1)];

    % Main loop
    for n = 1:N-r
       num = 0;
       T_tilde = zeros(r,1);
       for k = 1:r
         T_tilde(k) = 0; 
         for m = 1:(n-1)
            T_tilde(k) = T_tilde(k)+(Dbeta(m))*phi(m);
         end
         num = num+(ym(n+k-1)-T_tilde(k))*beta(k);
       end
       phi(n) = num/den;
    end

end