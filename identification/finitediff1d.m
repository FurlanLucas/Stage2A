function [timeOut, y] = finitediff1d(dataIn, h, M, N)
    %% finitediff1D
    %
    % Il fait l'implantation du méthode de differences finites 1D pour
    % l'équation du chaleur. L'équation a été implanté avec les méthode
    % implicite.
    %
    %
    % Entrées :
    % 
    %   - dataIn : variable iddata avec l'entrée qui va être simulée. Les
    %   information des coefficients thermiques du material et les autres
    %   carachteristiques comme la masse volumique sont estoquées dans le
    %   champs UserData dedans dataIn.
    %   - M : Nombre de nodes dans la variable x. Il doit être un intier.
    %   - dt : Discretization du temps.
    %

    %% Entrées
    % Caracteristiques thermiques du système
    e = dataIn.UserData.e;
    a = dataIn.UserData.a;
    lambda = dataIn.UserData.lambda;
    timeIn = dataIn.SamplingInstants/1e3;
    factor = dataIn.UserData.S_res/dataIn.UserData.takeArea;
    phiIn = dataIn.u*factor;

    % Differences finites
    dt = timeIn(end)/(N-1);
    dx = e/(M-1);
    tau = a*dt/(dx*dx);
    
    % Résolution du système lineaire
    y = zeros(1,N);
    timeOut = (0:N-1)*dt;
    phi = interp1(timeIn, phiIn, timeOut);
    T0 = zeros(M, 1);
    T = T0;

    %%
    for i = 1:N-1
        A = diag(-tau*ones(1,M-1),1) + diag(-tau*ones(1,M-1), -1) + ...
            diag((2+2*tau)*ones(1,M));
        A(1,2) = -2*tau; A(M,M-1) = -2*tau;
        B = diag(tau*ones(1,M-1),1) + diag(tau*ones(1,M-1), -1) + ...
            diag((2-2*tau)*ones(1,M));
        B(1,2) = 2*tau; B(M,M-1) = 2*tau;
        newnew = T(end)*h;
        c = [2*tau*dx*((phi(i)+phi(i+1)))/lambda; zeros(M-2,1); ...
            -2*tau*dx*((2*newnew))/lambda];
        T = A\(B*T + c); 
        y(i+1) = T(end);
    end

    %% Main