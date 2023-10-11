function u = prbs_gen(P, minFreq, amp)
    %% prbs
    %
    %

    %% Inputs
    maxOrder = 10;
    minOrder = 2;

    P_ = round(P*minFreq);

    possibleValues = minOrder:maxOrder;
    pos = sum(2.^possibleValues>P_);
    n = possibleValues(pos);

    u = zeros(P_, 1);
    %% Table

    table = {[1,2], [1,3], [1,4], [2,5], [1,6], [3,7], [1,2,7,8], [4,9], ...
        [7,10], [9,11]};

    %% Main
    G = zeros(1, n); G(table{pos-1}) = ones(size(table{pos-1}));
    A = [G; [eye(n-1), zeros(n-1,1)]];

    x = ones(n, 1); 
    x = randn(n,1)>0.5;
    for i = 1:P_
        x = A*x;
        if ~sum(x==0)
            x(1) = 1;
        end
        x(1) = mod(x(1)+1, 2);
        u(i) = x(1);
    end
   
    u = (repelem(u, round(1/minFreq)) * amp(2) - amp(1)) + amp(1);
    u = u(1:P);

    %% Plot
    %figure, plot(u)
        
end