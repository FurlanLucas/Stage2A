load("J_roots.mat");
lambda = 15;
h = 20;
R = 0.073; 
M = 5;

f = @(alpha_n) besselj(0,alpha_n*R) - ...
    (lambda/h)*besselj(1,alpha_n*R).*alpha_n;

figure; hold on;
aa = 0:0.01:200;
plot(aa, f(aa), 'b'); hold on; grid minor;

alpha = zeros(M,1);

alpha(1) = bissec(f, 0, J0(1)/R);
alpha(2) = bissec(f, J1(1)/R, J0(2)/R);
for i = 3:2:M-1+mod(M,2)
   alpha(i) = bissec(f, J1(i-1)/R, J0(i)/R);
   alpha(i+1) = bissec(f, J1(i)/R, J0(i+1)/R);
end

plot(alpha, f(alpha), 'or', MarkerFaceColor='r');