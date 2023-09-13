function u = seq_id_imp2(ym,h,r,dt)
    %% seq
    %
    %
    %
    
    %% Inputs
    
    % Alocating memory
    N = length(ym);
    u = zeros(N,1);
    phi = zeros(r,1);
    
    % Step response
    for m = 1:r
        phi(m) = 0;
        for i = 1:m
            phi(m) = phi(m)+h(i);
        end
    end
    
    % Denominator (phi^2)
    den = 0; 
    for m = 1:r
        den = den+phi(m)^2;
    end
    
    
    t = dt;
    for k = 1:N-r
       t = t+dt;
       num = 0;
       T_tilde = zeros(r,1);
       for m = 1:r
         T_tilde(m) = 0; 
         for i = 1:(k-1)
            T_tilde(m) = T_tilde(m)+phi(k-i+m)*u(i);
         end
         num = num+(ym(k+m-1)-T_tilde(m))*phi(m);
       end
       u(k) = num/den;
    end
