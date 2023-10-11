for i = 1:4
    modelsBack(i) = convergence(getexp(expData, i-1), 4, 10, type=1, ...
        finalOrder=4, minOrder=4);   
end




for i = 2:8
    modelsBack(i) = convergence(identData, i, 10, type=1, ...
        finalOrder = i, minOrder=i);
    residuesBack = validation(validData, modelsBack, type=1, straight=true);

    err(i) = 0;
    for j = 1:length(residuesBack.ARMAX)
        err = err + sum(abs(residuesBack.ARMAX{j}))/length(residuesBack.ARMAX{j});
    end
end