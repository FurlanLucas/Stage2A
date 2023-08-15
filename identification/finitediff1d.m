function [y, timeOut] = finitediff1d(dataIn, timeIn, phiIn, h, M, N)
    %% finitediff1D
    %
    % Function that implements the finite difference method in a 1D
    % analysis of the heat equation with a axisymetric system. It is used
    % the implicit method.
    %
    % Calls
    %
    %   [y, timeOut] = finitediff1d(dataIn, timeIn, phiIn, h, M, N):
    %   calls the function for the data in dataIn. The time vector that
    %   will be used and the heat flux applied to the front face (x = 0) is
    %   giving in timeIn and phiIn, respectively. The heat transfert
    %   coefficient is giving by h. Mx and N are the number of elements
    %   in x directions and in time, respectively.
    %
    % Inputs
    %
    %   dataIn: sysData variable with all the information for the
    %   system that will be simulated. It is possible also use a structure 
    %   with the same fields as a sysDataType;
    %
    %   h: vector of heat transfer coefficients in W/(m²K);
    %
    %   M: Number of elements in x direction. Have to be an integer;
    %
    %   N: Number of elements in time. Have to be an integer.
    %
    % Outputs
    %
    %   y: 2x1 cell array with the temperature variation outout of the 
    %   system. The first {1} position corresponds to the rear face and the 
    %   second one to front face.
    %
    %   timeOut: time vector with each simulation instant.
    %
    % See also sysDataType, model_1d, model_1d_pade and model_1d_taylor.

    %% Inputs

    % Thermal coefficients and geometry
    ell = dataIn.ell;
    a = dataIn.a;
    lambda = dataIn.lambda;

    % Finite differences
    dt = timeIn(end)/(N-1);
    dx = ell/(M-1);
    tau = a*dt/(dx*dx);
    
    % Initialize variables
    y_back = zeros(1,N); y_front = zeros(1,N);
    timeOut = (0:N-1)*dt;
    phi = interp1(timeIn, phiIn, timeOut);
    T0 = zeros(M, 1);
    T = T0;

    %% Main

    for i = 1:N-1
        % Matrix A
        A = diag(-tau*ones(1,M-1),1) + diag(-tau*ones(1,M-1), -1) + ...
            diag((2+2*tau)*ones(1,M));
        A(1,2) = -2*tau; A(M,M-1) = -2*tau;

        % Matrix B
        B = diag(tau*ones(1,M-1),1) + diag(tau*ones(1,M-1), -1) + ...
            diag((2-2*tau)*ones(1,M));
        B(1,2) = 2*tau; B(M,M-1) = 2*tau;

        % Vector c
        c = [2*tau*dx*((phi(i)+phi(i+1)))/lambda; zeros(M-2,1); ...
             -4*tau*dx*(T(end)*h)/lambda];

        % Result
        T = A\(B*T + c); 
        y_back(i+1) = T(end);
        y_front(i+1) = T(1);
    end

    %% Output
    y = {y_back, y_front};

end