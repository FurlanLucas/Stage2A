 clc; clear; close all;
%% Entrées et constantes
lambda = 16.3;          % [W/mK] Conductivité thermique ;
rho = 8010;             % [kg/m³] Masse volumique ;
cp = 502;               % [J/kgK] Capacité thermique massique ;
a = lambda/(rho*cp);    % [m^2/s] Diffusivité thermique ;
e = 5e-3;               % [m] Epaisseur plaque ;
h = 200;                  % [W/m²K] Coefficent de transfert thermique ;
Ly = 10;                % [m] Longeur en y ;
Lz = 10;                % [m] Longeur en z ; 

% Paramètres de la simulation et données
figDir = 'fig';              % [-] Emplacement pour les figures générées ;
order = [1 3 6 11];          % Ordre pour l'approximation de Pade ;
colors = ['r','b','g','m'];  % Couleurs pour les graphes de << orders >> ;
wmin = 1e-2;                 % [rad/s] Fréquence minimale pour le bode ;
wmax = 1e3;                  % [rad/s] Fréquence maximale pour le bode ;
wpoints = 1000;              % [rad/s] Nombre des fréquences ;  
No = [3 5 7];                % [-] Nombre des solutions en y ;
y = 0/2;                     % [m] Position en y à être analysée ;
Mo = [3 5 7];                % [-] Nombre des solutions en z ; 
z = 0/2;                     % [m] Position en z à être analysée ;
types = ["--" ":" "-." "-"]; % [-] Line styles for plots ;

%% Coeficientes theoriques et vecteurs
w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur de fréquences
k = sqrt(w*1j/a); % Résolution de l'équation en 1D
C = lambda*k.*sinh(e*k);
A = h*cosh(e*k);

%% Modèle de F(s) en 1D (sans pertes)
Fs_th = 1./C; % Modèle théorique sans pertes
mag_th = abs(Fs_th);
phase_th = angle(Fs_th);

% Figure (comparaison entre le modèle avec et sans pertes)
fig = figure; subplot(2,1,1);
semilogx(w,20*log10(mag_th),'b',LineWidth=1.4, DisplayName='Sans pertes'); 
hold on; subplot(2,1,2);
semilogx(w, phase_th*180/pi, 'b', LineWidth=1.4); hold on;

%% Modèle de F(s) en 1D (avec pertes)
Fs_th = 1./(C + A*h);
mag_th = abs(Fs_th);
phase_th = angle(Fs_th);

% Figure (comparaison entre le modèle avec et sans pertes)
subplot(2,1,1);
semilogx(w,20*log10(mag_th), 'r', LineStyle=types(1), LineWidth=1.4, ...
    DisplayName='Avec pertes');
ylabel('Mag (dB)', Interpreter='latex', FontSize=17);
grid minor; hold off; 
legend(Interpreter="latex", FontSize=12, Location="southwest");
subplot(2,1,2);
semilogx(w, phase_th*180/pi, 'r', LineStyle=types(1), LineWidth=1.4, ...
    DisplayName='Avec pertes');
grid minor; hold off;
ylabel('Phase (deg)', Interpreter='latex', FontSize=17);
xlabel("Fr\'{e}quences (rad/s)", Interpreter='latex', FontSize=17);
saveas(fig, figDir+"\avecEtSansPertes1D.png");
sgtitle("R\'{e}ponse en fr\'{e}quence de $F_{1D}(s)$", ...
    Interpreter='latex', FontSize=21);

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
    N = changeVariable(N(mod(fliplr(1:length(N)),2)==1), [e^2/a 0]);
    D = changeVariable(D(mod(fliplr(1:length(D)),2)==1), [e^2/a 0]);
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
sgtitle("R\'{e}ponse en fr\'{e}quence de $F_{1D}(s)$", ...
    Interpreter='latex', FontSize=21);

%% Mes fonctions
function P = polyPower(Q, n)
    % Il va evaluer le polynôme Q(x) à la puissance n, c'est à dire
    % P(x) = [Q(x)]^n. Si n = 0, donc P(x) = 1.
    
    % Prendre les cas plus simples
    if n == 0
        P = 1;
        return
    elseif n == 1
        P = Q;
        return
    % Le  cas générale
    else
        P = conv(Q, Q); % Il va faire n fois la convolution de Q
        for i = 3:n
            P = conv(P, Q);
        end
    end
end

function R = sumPoly(P, Q)
    % Prendre la summe de deux polynômes P(x) et Q(x). IL faut aligner les
    % deux vecteur de coefficientes dans un façon que il sera possibles de
    % les ajouter.
    
    % Prendre l'ordre plus grande
    P_order = length(P);
    Q_order = length(Q);
    if P_order > Q_order
         max_order = size(P);
    else
         max_order = size(Q);
    end

    % Ajoute les deux polynômes
    new_P = padarray(P, max_order-size(P), 0, 'pre');
    new_Q = padarray(Q, max_order-size(Q), 0, 'pre');
    R = new_P + new_Q;
end

function R = changeVariable(Q, P)
    % IL va changer la variable du polinôme Q(y) pour y = P(x) et retourner
    % un nouvel polynôme R(x) = Q(P(x)). Des convolution sucessives sont
    % utilisées.
    % R(x) = sum( r_i * x^i ) ;
    %      = sum( q_i * (p(x))^i ) ;

    R = 0;
    for i=0:length(Q)-1
        R = sumPoly(R, Q(length(Q)-i)*polyPower(P, i));
    end
end