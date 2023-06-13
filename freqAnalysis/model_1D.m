 clc; clear; close all;
%% Entrées et constantes
lambda = 16.3;          % [W/mK] Conductivité thermique ;
%lambda = 1;
rho = 8010;             % [kg/m³] Masse volumique ;
cp = 502;               % [J/kgK] Capacité thermique massique ;
%cp = 1200;
a = lambda/(rho*cp);    % [m^2/s] Diffusivité thermique ;
e = 5e-3;               % [m] Epaisseur plaque ;
h = 2;                % [W/m²K] Coefficent de transfert thermique ;
Ly = 10;                % [m] Longeur en y ;
Lz = 10;                % [m] Longeur en z ; 

% Paramètres de la simulation et données
figDir = 'fig';             % [-] Emplacement pour les figures générées ;
order = [1 3 6 11];      % Ordre pour l'approximation de Pade ;
colors = ['r','b','g','m']; % Couleurs pour les graphes de << orders >> ;
wmin = 1e-2;                % [rad/s] Fréquence minimale pour le bode ;
wmax = 1e3;                 % [rad/s] Fréquence maximale pour le bode ;
wpoints = 1000;             % [rad/s] Nombre des fréquences ;  
No = [3 5];            % [-] Nombre des solutions en y ;
y = 0/2;                   % [m] Position en y à être analysée ;
Mo = [3 5];            % [-] Nombre des solutions en z ; 
z = 0/2;                   % [m] Position en z à être analysée ;
types = ["--" ":"];
%% Coeficientes theoriques et vecteurs
w = logspace(log10(wmin), log10(wmax), wpoints);
k = sqrt(w*1j/a); % Résolution de l'équation en 1D
C = lambda*k.*sinh(e*k);
A = h*cosh(e*k);

%% Modèle de F(s) en 1D (sans pertes)
Fs_th = 1./C; % Modèle théorique sans pertes
mag_th = abs(Fs_th);
phase_th = angle(Fs_th);

% Figure (comparaison entre le modèle avec et sans pertes)
fig = figure; subplot(2,1,1);
semilogx(w,20*log10(mag_th),'b',LineWidth=1.4,DisplayName='Sans pertes'); 
hold on; subplot(2,1,2);
semilogx(w, phase_th*180/pi, 'b', LineWidth=1.4); hold on;

%% Modèle de F(s) en 1D (avec pertes)
Fs_th = 1./(C + A*h);
mag_th = abs(Fs_th);
phase_th = angle(Fs_th);

% Figure (comparaison entre le modèle avec et sans pertes)
subplot(2,1,1);
semilogx(w,20*log10(mag_th),'r',LineWidth=1.4,DisplayName='Avec pertes');
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
grid minor; hold off; 
legend(Interpreter="latex", FontSize=12, Location="southwest");
subplot(2,1,2);
semilogx(w, phase_th*180/pi,'r',LineWidth=1.4,DisplayName='Avec pertes');
grid minor; hold off;
ylabel('Phase (deg)', Interpreter='latex', FontSize=17);
xlabel("Fr\'{e}quences (rad/s)", Interpreter='latex', FontSize=17);
saveas(fig, figDir+"\avecEtSansPertes1D.png");

%% Pade approx pour le modèle 1D (avec pertes)

fig = figure; % Il crée la figure pour diferentes ordres d'approximation

for i=1:length(order)
    A = [lambda/(2*e), h/2]; % Polinôme en xi
    B = [-lambda/(2*e), h/2]; % Polinôme en xi
    [P,Q] = padecoef(1,order(i)); % Aproximation e^(x) = P(xi)/Q(xi)

    % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
    N = conv(P,Q); 
    D = conv(conv(Q,Q), A) + conv(conv(P,P), B);

    % Passe à la variable de Laplace s = (a/e^2)xi
    factor = (e^2/a).^(fliplr(0:order(i)));  % Facteur entre xi et s
    N = N(mod(fliplr(1:length(N)),2)==1).*factor; % Change par s (num.)
    D = D(mod(fliplr(1:length(D)),2)==1).*factor; % Change par s (dem.)
    N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)

    % Diagramme de bode
    F_approx_ev = polyval(N,w*1j)./polyval(D,w*1j);
    mag_approx = abs(F_approx_ev);
    phase_approx = angle(F_approx_ev);

    % Figure
    subplot(2,1,1);
    semilogx(w,20*log10(mag_approx), colors(i), LineWidth=1.4, ...
        DisplayName="Pade $N="+num2str(order(i))+"$");  hold on;
    subplot(2,1,2);
    semilogx(w, phase_approx*180/pi, colors(i), LineWidth=1.4); hold on;
end

% Sauveguarde la fonction transfert
Fs_approx = tf(N, D);
save('..\identification\Fs_pade', 'Fs_approx');

% Configurations graphiques finales (comparaison pour les ordres en 1D)
subplot(2,1,1);
semilogx(w,20*log10(mag_th),'k',LineWidth=1.4,DisplayName='Theorique');
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
grid minor; hold off; 
legend(Interpreter="latex", FontSize=12, Location="southwest");
subplot(2,1,2);
semilogx(w, phase_th*180/pi,'k',LineWidth=1.4);
grid minor; hold off;
ylabel('Phase (deg)', Interpreter='latex', FontSize=17);
xlabel("Fr\'{e}quences (rad/s)", Interpreter='latex', FontSize=17);
fig.Position = [341 162 689 418];
saveas(fig, figDir+"\padeApprox.png");

%% Modèle de F(s) en 3D (sans pertes en y et z)

% Figure (comparaison entre les 1D et 3D)
fig = figure; subplot(2,1,1);
semilogx(w,20*log10(mag_th),'k',LineWidth=1.4,DisplayName="Mod\'{e}le 1D"); 
hold on; subplot(2,1,2);
semilogx(w, phase_th*180/pi, 'k', LineWidth=1.4); hold on;

for k = 1:length(Mo)
    Fs_3D = zeros(size(w));
    for n = 0:No(k)
        alpha = n*pi/Ly;
        Y = cos(alpha*y);
        Nalpha = Ly/2; % Norme N(alpha_n) pour Y(alpha_n, y)
        for m = 0:Mo(k)
            beta = m*pi/Lz;
            Z = cos(beta*z);
            Mbeta = Lz/2; % Norme M(beta_m) pour Z(beta_m, z)
    
            % Résolution
            gamma = sqrt(1j*w/a + alpha^2 + beta^2);
            C = lambda*gamma.*sinh(e*gamma);
            A = h*cosh(e*gamma);
            Fs_th = 1./(C + A*h);

            % Utilise la même théorie que en 1D
            if alpha == 0 && beta == 0
                newF = Lz*Ly;
            elseif alpha == 0
                newF = Ly*sin(beta*Lz)/beta;
            elseif beta == 0                
                newF = Lz*sin(alpha*Ly)/alpha;
            else
                newF = sin(alpha*Ly)*sin(beta*Lz)/(beta*alpha);
            end
            Fs_3D = Fs_3D + (Fs_th)*(Y/Nalpha)*(Z/Mbeta)*newF;
        end
    end
    % Plot
    mag_3D = abs(Fs_3D);
    phase_3D = angle(Fs_3D);
    subplot(2,1,1);
    semilogx(w,20*log10(mag_3D), types(k)+colors(k), LineWidth=1.4, ...
        DisplayName="3D O = "+num2str(No(k)));
    subplot(2,1,2);
    semilogx(w, phase_3D*180/pi, types(k)+colors(k), LineWidth=1.4);
end


% Configurations graphiques finales (comparaison pour les ordres en 1D)
subplot(2,1,1);
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
grid minor; hold off; 
legend(Interpreter="latex", FontSize=12, Location="southwest");
subplot(2,1,2);
grid minor; hold off;
ylabel('Phase (deg)', Interpreter='latex', FontSize=17);
xlabel("Fr\'{e}quences (rad/s)", Interpreter='latex', FontSize=17);
fig.Position = [341 162 689 418];
saveas(fig, figDir+"\1D_et_3D.png");


