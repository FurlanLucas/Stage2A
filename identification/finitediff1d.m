function [y, timeOut] = finitediff1d(dataIn, timeIn, phiIn, h, M, N)
    %% finitediff1D
    %
    % Il fait l'implantation du méthode de differences finites 1D pour
    % l'équation du chaleur. L'équation a été implanté avec les méthode
    % implicite. L'algorithime utilisé peut être vu dans le livre <<
    % Calculo Numérico >> de Neide Franco.
    %
    % EXAMPLE D'APPELL :
    %
    %   finitediff1d(dataIn, h, M, N) : pour analyser les données experimental
    %   dedans dataIn. dataIn doit être une variable du type iddata avec un
    %   champs UserData comme sysDataType.
    %
    %   compare_results(__, options) : pour données des autres options à
    %   l'analyse.
    %
    % EENTRÉES :
    % 
    %   - dataIn : variable iddata avec l'entrée qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs UserData dedans dataIn. Il sera estoqué comme sysDataType.
    %
    %   - M : Nombre de nodes dans la variable x. Il doit être un intier.
    %
    %   - dt : Nombre des pas pour la discretization du temps. Il doit
    % être un intier
    %
    % OPTIONS :
    %
    % See compare_results, iddata, sysDataType.

    %% Entrées

    % Caracteristiques thermiques du système
    ell = dataIn.ell;
    a = dataIn.a;
    lambda = dataIn.lambda;

    % Differences finites
    dt = timeIn(end)/(N-1);
    dx = ell/(M-1);
    tau = a*dt/(dx*dx);
    
    % Résolution du système lineaire
    y_back = zeros(1,N); y_front = zeros(1,N);
    timeOut = (0:N-1)*dt;
    phi = interp1(timeIn, phiIn, timeOut);
    T0 = zeros(M, 1);
    T = T0;

    %% Main

    for i = 1:N-1
        % Matrice A
        A = diag(-tau*ones(1,M-1),1) + diag(-tau*ones(1,M-1), -1) + ...
            diag((2+2*tau)*ones(1,M));
        A(1,2) = -2*tau; A(M,M-1) = -2*tau;

        % Matrice B
        B = diag(tau*ones(1,M-1),1) + diag(tau*ones(1,M-1), -1) + ...
            diag((2-2*tau)*ones(1,M));
        B(1,2) = 2*tau; B(M,M-1) = 2*tau;

        % Vecteur c
        c = [2*tau*dx*((phi(i)+phi(i+1)))/lambda; zeros(M-2,1); ...
             -4*tau*dx*(T(end)*h)/lambda];

        % Résultat
        T = A\(B*T + c); 
        y_back(i+1) = T(end);
        y_front(i+1) = T(1);
    end

    %% Sortie
    y = {y_back, y_front};

end