function [y, timeOut] = finitediff2d(dataIn, timeIn, phiIn, h, Mx, Mr, N)
    %% finitediff2D
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
    ell = dataIn.ell;
    a = dataIn.a;
    lambda = dataIn.lambda;
    r = dataIn.size;

    % Differences finies
    dt = timeIn(end)/(N-1);
    dx = ell/(Mx-1);
    dr = r/(Mr-1);
    r = (1:Mr)*dr;
    timeOut = (0:N-1)*dt;
    phi = interp1(timeIn, phiIn, timeOut);

    if strcmp(dataIn.resGeometry, 'Circ')
        r0 = dataIn.resSize;
    else
        r0 = dataIn.resSize; %/sqrt(pi);
    end
    r0 = Inf;


    myphi = @(ri, ni) myphiFF(ri, r0, phi(ni));

    hr = h;
    hx = h;


    %% A Matrix
    %T = 500*ones(Mx*Mr, 1);
    T = zeros(Mx*Mr, 1);
    c = zeros(Mx*Mr, 1);
    y = zeros(1,N);

    for n = 1:N
        A = zeros(Mx*Mr);

        for i = 1:Mr
            for j=1:Mx
                pos = i + Mr*(j-1);
                
                R1 = a*dt/(dr^2);
                R2 = a*dt/(r(i)*2*dr);
                R3 = a*dt/(dx^2);
                
                % Interior da malha
                if (i > 1) && (i < Mr) && (j > 1) && (j < Mx)
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 1 - 2*R1 - 2*R3;
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira inferior em j (dentro em i)
                elseif (j == 1) && (i ~= 1) && (i ~= Mr)
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 1 - 2*R1 - 2*R3;
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*(myphi(r(i), n))/lambda;

                % Fronteira superior em j (dentro em i)
                elseif (j == Mx) && (i ~= 1) && (i ~= Mr)
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 1 - 2*R1 - 2*R3 - R3*(2*dx*hx/lambda);
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos-Mr) = 2*R3; 

                % Fronteira inferior em i (dentro em j)
                elseif (i == 1) && (j ~= 1) && (j ~= Mx)
                    A(pos, pos) = 1 - 2*R1 - 2*R3;
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira superior em i (dentro em j)
                elseif (i == Mr) && (j ~= 1) && (j ~= Mx)
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 1 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda);
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira infeior em i e j
                elseif (i == 1) && (j == 1)
                    A(pos, pos) = 1 - 2*R1 - 2*R3;
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*(myphi(r(i), n))/lambda;
                  
                % Fronteira inferior em j e superior em i
                elseif (j == 1) && (i == Mr)
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 1 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda);
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*(myphi(r(i), n))/lambda;

                % Fronteira inferior em i e superior em j
                elseif (i == 1) && (j == Mx)
                    A(pos, pos) = 1 - 2*R1 - 2*R3 - R3*(2*dx*hx/lambda);
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos-Mr) = 2*R3;

                % Fronteira superior em i et j
                elseif (i == Mr) && (j == Mx)
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 1 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda)...
                        - R3*(2*dx*hx/lambda);
                    A(pos, pos-Mr) = 2*R3;
                else
                    error("You not suppose to see this.")
                end

                
            end
        end

        T = A*T + c;
        y(n) = T(Mr*Mx-Mr+1);
    end
end

function out = myphiFF(ri, r0, in)
    if ri <= r0
        out = in;
    else 
        out = 0;
    end
end