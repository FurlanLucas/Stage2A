function [y, timeOut] = finitediff2d_v2(dataIn, timeIn, phiIn, h, Mx, Mr, N)
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
    lambda_x = dataIn.lambda;
    lambda_r = dataIn.lambda;
    Rmax = dataIn.size;
    r0 = dataIn.resSize;
    %r0 = Rmax;
    %r0 = 35.6e-3;

    % Differences finies
    dt = timeIn(end)/(N-1);
    dx = ell/(Mx-1);
    dr = Rmax/(Mr-1);
    r = (0:Mr-1)*dr;
    timeOut = (0:N-1)*dt;
    phi = interp1(timeIn, phiIn, timeOut);
    myphi = phi .* (r' <= r0);

    hr = h;
    hx = h;


    %% A Matrix
    T = zeros(Mx*Mr, 1);
    y = zeros(1,N);

    count = 0;
    for n = 2:N
        A = zeros(Mx*Mr);
        B = zeros(Mx*Mr);
        c = zeros(Mx*Mr, 1);

        for i = 1:Mr
            for j=1:Mx
                pos = i + Mr*(j-1);
                
                R1 = a*dt/(dr^2);
                R2 = a*dt/(2*r(i)*dr);
                R3 = a*dt/(dx^2);
                
                % Interior da malha
                if (i > 1) && (i < Mr) && (j > 1) && (j < Mx)
                    B(pos, pos-1) = R2 - R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3;
                    B(pos, pos+1) = -R1 - R2;
                    B(pos, pos-Mr) = -R3;
                    B(pos, pos+Mr) = -R3;
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 2 - 2*R1 - 2*R3;
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira inferior em j (dentro em i)
                elseif (j == 1) && (i ~= 1) && (i ~= Mr)
                    B(pos, pos-1) = R2 - R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3;
                    B(pos, pos+1) = -R1 - R2;
                    B(pos, pos+Mr) = -2*R3;
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 2 - 2*R1 - 2*R3;
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*( (myphi(i, n) + myphi(i, n-1) )...
                                          )/lambda_x;

                % Fronteira superior em j (dentro em i)
                elseif (j == Mx) && (i ~= 1) && (i ~= Mr)
                    B(pos, pos-1) = R2 - R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3 + R3*(2*dx*hx/lambda_x);
                    B(pos, pos+1) = -R1 - R2;
                    B(pos, pos-Mr) = -2*R3;
                    A(pos, pos-1) = R1 - R2;
                    A(pos, pos) = 2 - 2*R1 - 2*R3 - R3*(2*dx*hx/lambda_x);
                    A(pos, pos+1) = R1 + R2;
                    A(pos, pos-Mr) = 2*R3; 

                % Fronteira inferior em i (dentro em j)
                elseif (i == 1) && (j ~= 1) && (j ~= Mx)
                    B(pos, pos) = 2 + 2*R1 + 2*R3;
                    B(pos, pos+1) = -2*R1;
                    B(pos, pos-Mr) = -R3;
                    B(pos, pos+Mr) = -R3;
                    A(pos, pos) = 2 - 2*R1 - 2*R3;
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira superior em i (dentro em j)
                elseif (i == Mr) && (j ~= 1) && (j ~= Mx)
                    B(pos, pos-1) = - 2*R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3 + (R1+R2)*(2*dr*hr/lambda_r);
                    B(pos, pos-Mr) = -R3;
                    B(pos, pos+Mr) = -R3;
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 2 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda_r);
                    A(pos, pos-Mr) = R3;
                    A(pos, pos+Mr) = R3;

                % Fronteira infeior em i e j
                elseif (i == 1) && (j == 1)
                    B(pos, pos) = 2 + 2*R1 + 2*R3;
                    B(pos, pos+1) = -2*R1;
                    B(pos, pos+Mr) = -2*R3;
                    A(pos, pos) = 2 - 2*R1 - 2*R3;
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*( (myphi(i, n) + myphi(i, n-1) )...
                                          )/lambda_x;
                  
                % Fronteira inferior em j e superior em i
                elseif (j == 1) && (i == Mr)
                    B(pos, pos-1) = -2*R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3 + (R1+R2)*(2*dr*hr/lambda_r);
                    B(pos, pos+Mr) = -2*R3;
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 2 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda_r);
                    A(pos, pos+Mr) = 2*R3;
                    c(pos) = R3*2*dx*( (myphi(i, n) + myphi(i, n-1) )...
                                          )/lambda_x;

                % Fronteira inferior em i e superior em j
                elseif (i == 1) && (j == Mx)
                    B(pos, pos) = 2 + 2*R1 + 2*R3 + R3*(2*dx*hx/lambda_x);
                    B(pos, pos+1) = -2*R1;
                    B(pos, pos-Mr) = -2*R3;
                    A(pos, pos) = 2 - 2*R1 - 2*R3 - R3*(2*dx*hx/lambda_x);
                    A(pos, pos+1) = 2*R1;
                    A(pos, pos-Mr) = 2*R3;

                % Fronteira superior em i et j
                elseif (i == Mr) && (j == Mx)
                    B(pos, pos-1) = -2*R1;
                    B(pos, pos) = 2 + 2*R1 + 2*R3 + (R1+R2)*(2*dr*hr/lambda_r)...
                        + R3*(2*dx*hx/lambda_x);
                    B(pos, pos-Mr) = -2*R3;
                    A(pos, pos-1) = 2*R1;
                    A(pos, pos) = 2 - 2*R1 - 2*R3 - (R1+R2)*(2*dr*hr/lambda_r)...
                        - R3*(2*dx*hx/lambda_x);
                    A(pos, pos-Mr) = 2*R3;
                else
                    error("Il y a un cas non specifié.");
                end

                
            end
        end

        p = floor(100*n/N);
        if p > count
            fprintf("\t\tAnalyse en %2d%%.\n", p);
            count = count + 1;
        end

        T = B\(A*T + c);
        y(n) = T(Mr*Mx-Mr+1);

    end % end for

end % end function
