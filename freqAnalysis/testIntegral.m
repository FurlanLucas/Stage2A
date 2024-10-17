R0 = 0.3;
alpha = [1.2 0];
n = 0;

int_R = (besselj(0, alpha*Rmax) .^ 2).*((Rmax * alpha).^2 + ...
        (Rmax * hr2 / lambda_r)^2)./(2*(alpha.^2));
int2 = integral(@(r) r.*besselj(1, alpha(n+1)*r).^2, 0, R0);
