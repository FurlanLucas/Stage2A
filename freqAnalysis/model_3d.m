clc; clear; close all;
%% Model_3d
% Modèle 3D du système thermique étudié, developé pour une transfert de
% chaleur dans la direction x. Il est supposé des conductivités thermique
% differentes en chaque direction (x, z, y) et aussi differentes
% coefficientes de transfert thermique dans les surfaces du solide. IL ne
% suppose pas une perte de chaleur en x = 0 et on a que l'entrée de flux de
% chaleur (phi_1).
%
% Voir la fonction model_1D pour la résolution en 1D et le rapport pour une
% description plus grande.

%% Entrées et constantes
lambda_x = 16.3;          % [W/mK] Conductivité thermique ;
lambda_y = 55.3;          % [W/mK] Conductivité thermique ;
lambda_z = 1.3;           % [W/mK] Conductivité thermique ;
rho = 8010;               % [kg/m³] Masse volumique ;
cp = 502;                 % [J/kgK] Capacité thermique massique ;
a_x = lambda_x/(rho*cp);  % [m^2/s] Diffusivité thermique ;
e = 5e-3;                 % [m] Epaisseur plaque ;
hx2 = 1;                  % [W/m²K] Coefficient de transfert thermique (x);
hy1 = 100;                % [W/m²K] Coefficient de transfert thermique (y);
hy2 = 200;                % [W/m²K] Coefficient de transfert thermique (y);
hz1 = 10;                 % [W/m²K] Coefficient de transfert thermique (z);
hz2 = 20;                 % [W/m²K] Coefficient de transfert thermique (z);
Ly = 1;                   % [m] Longeur en y ;
Lz = 1;                   % [m] Longeur en z ; 

% Paramètres de la simulation et données
figDir = 'fig';              % [-] Emplacement pour les figures générées ;
order = [1 3 6 11];          % Ordre pour l'approximation de Pade ;
colors = ['r','b','g','m'];  % Couleurs pour les graphes de << orders >> ;
wmin = 1e-2;                 % [rad/s] Fréquence minimale pour le bode ;
wmax = 1e3;                  % [rad/s] Fréquence maximale pour le bode ;
wpoints = 1000;              % [rad/s] Nombre des fréquences ; 
correc = 1e-8;              % [-] Paramètre de correction numérique ;
No = [1 3 6];                % [-] Nombre des solutions en y ;
No_plot = 5;                 % [-]
Mo = [1 3 6];                % [-] Nombre des solutions en z ; 
y = 0;                       % [m] Position en y à être analysée ;
z = 0;                       % [m] Position en z à être analysée ;
types = ["--" ":" "-." "-"]; % [-] Line styles for plots ;

%% Coeficientes theoriques et vecteurs
w = logspace(log10(wmin), log10(wmax), wpoints); % Vecteur de fréquences
k = sqrt(w*1j/a_x); % Résolution de l'équation en 1D
C = lambda_x*k.*sinh(e*k);
A = hx2*cosh(e*k);

% Nombres de Biot
Hy1 = hy1*Ly/lambda_y; % Convection naturelle en y1
Hy2 = hy2*Ly/lambda_y; % Convection naturelle en y2
Hz1 = hz1*Lz/lambda_z; % Convection naturelle en z1
Hz2 = hz2*Lz/lambda_z; % Convection naturelle en z2

%% Équation transcedentes (y)
% Résolution de l'équation transcedente en alpha_n et beta_m, aussi bien
% que le calcul des modules N(alpha_n) et M(beta_m). Premièrement, il
% montre les deux fonctions liées à l'équation pour vérifier les résultats
% possibles.

% Figure avec les racines de la fonction en alpha_n (illustrative)
fig = figure; hold on;
alpha_n = linspace(0.05, pi-0.05 + No_plot*pi, 1000)/Ly;
eq = ((lambda_y*alpha_n).^2 - hy1*hy2)./(lambda_y*alpha_n*(hy1+hy2));
plot(alpha_n, eq, 'k', LineWidth=1.7);
for n=0:No_plot
    % Fonctions
    alpha_n = linspace(0.05+n*pi, pi-0.05 + n*pi, 1000)/Ly;
    plot(alpha_n, cot(alpha_n*Ly), 'b', LineWidth=1.7);    

    f = @(alpha) cot(alpha*Ly) - ...
        ((lambda_y*alpha).^2 - hy1*hy2)./(lambda_y*alpha*(hy1+hy2));
    alpha_n = bissec(f, (n+correc)*pi/Ly, (n+1-correc)*pi/Ly);
    plot(alpha_n, cot(alpha_n*Ly), 'ro', MarkerFaceColor='r');
end
grid minor; ylim([-30 30])
xlabel('$\alpha_n$', Interpreter='latex', FontSize=17);
saveas(fig, figDir+"\eqTrans.png");
title("Solution d'\'{e}quation transcedente", Interpreter='latex', ...
    FontSize=21);

% Prendre les solutions pour alpha_n (dans la direction y)
alpha = zeros(1,No(end)+1);
f = @(alpha) cot(alpha*Ly) - ...
        ((lambda_y*alpha).^2 - hy1*hy2)./(lambda_y*alpha*(hy1+hy2));
for i=0:No(end)
    alpha(i+1) = bissec(f, (i+correc)*pi/Ly, (i+1-correc)*pi/Ly);
end
Nalpha = (1./(2*Ly*alpha.^2)).*( Hy1 + (Hy1^2 + (alpha*Ly).^2) .* ...
    (1 + Hy2./(Hy2^2 + (alpha*Ly).^2)) );

% Prendre les solutions pour beta_m (dans la direction z)
beta = zeros(1,Mo(end)+1);
f = @(beta) cot(beta*Lz) - ...
        ((lambda_z*beta).^2 - hz1*hz2)./(lambda_z*beta*(hz1+hz2));
for i=0:Mo(end)
    beta(i+1) = bissec(f, (i+correc)*pi/Lz, (i+1-correc)*pi/Lz);
end
Mbeta = (1./(2*Lz*beta.^2)).*( Hz1 + (Hz1^2 + (beta*Lz).^2) .* ...
    (1 + Hz2./(Hz2^2 + (beta*Lz).^2)) );

%% Modèle de F(s) en 1D (sans pertes)
Fs_th = 1./C; % Modèle théorique sans pertes pour comparaison
mag_th = abs(Fs_th);
phase_th = angle(Fs_th);

%% Modèle de F(s) en 3D (avec des pertes en y et z)
% Calcule de la solution 3D. Il y a trois boucles for differentes : le
% première change l'ordre de l'approximation et les autres deux boucles
% sont des séries en n et m de la solution.

% Figure (comparaison entre les 1D et 3D)
fig = figure; subplot(2,1,1);
semilogx(w,20*log10(mag_th),'k',LineWidth=1.4,DisplayName="Mod\'{e}le 1D"); 
hold on; subplot(2,1,2);
semilogx(w, phase_th*180/pi, 'k', LineWidth=1.4); hold on;

for k = 1:length(Mo) % Change l'ordre de l'approximation
    Fs_3D = zeros(size(w));  % Vecteur avec des solutions

    for n = 0:No(k) % Serie en y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:Mo(k) % Serie en z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);
    
            % Résolution en 1D
            gamma = sqrt(1j*w/a_x + alpha(n+1)^2 + beta(m+1)^2);
            C = lambda_x*gamma.*sinh(e*gamma);
            A = cosh(e*gamma);
            Fs_th = 1./(C + A*hx2);

            % Calcule le facteur de correction de la serie int(Y)*int(Z)
            if alpha(n+1) == 0
                int_Y = Ly;
            else
                int_Y = -sin(alpha(n+1)*Ly)/alpha(n+1) + ...
                    (hy1/(alpha(n+1)*lambda_x)) * ...
                    (cos(alpha(n+1)*Ly)/alpha(n+1) - 1/alpha(n+1));
            end
            if beta(m+1) == 0
                int_Z = Lz;
            else
                int_Z = -sin(beta(m+1)*Lz)/beta(m+1) + ...
                    (hz1/(beta(m+1)*lambda_z)) * ...
                    (cos(beta(m+1)*Lz)/beta(m+1) - 1/beta(m+1));
            end

            % Some les fonctions (serie en y et en z)
            Fs_3D = Fs_3D + (Fs_th) * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z*int_Y;
        end
    end

    % Diagramme de bode
    mag_3D = abs(Fs_3D);
    phase_3D = angle(Fs_3D);

    % Figure de comparaison
    subplot(2,1,1);
    semilogx(w,20*log10(mag_3D), types(k)+colors(k), LineWidth=1.4, ...
        DisplayName="3D O = "+num2str(No(k)));
    subplot(2,1,2);
    semilogx(w, phase_3D*180/pi, types(k)+colors(k), LineWidth=1.4);
end


% Configurations graphiques finales (comparaison pour les ordres en 3D)
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
sgtitle("R\'{e}ponse en fr\'{e}quence de $F(s)$", Interpreter='latex', ...
    FontSize=21);

%% Pade approx pour le modèle 3D (avec pertes)

% Figure (comparaison entre les approx de Pade)
fig = figure; subplot(2,1,1);
semilogx(w,20*log10(mag_3D),'k',LineWidth=1.4,DisplayName="Mod\'{e}le 1D"); 
hold on; subplot(2,1,2);
semilogx(w, phase_3D*180/pi, 'k', LineWidth=1.4); hold on;

for k = 1:length(Mo) % Change l'ordre de l'approximation
    Fs_3D_approx = zeros(size(w));  % Vecteur avec des solutions

    for n = 0:No(k) % Serie en y
        Y = cos(alpha(n+1)*y) + ...
            (hy1/(lambda_y*alpha(n+1)))*sin(alpha(n+1)*y);

        for m = 0:Mo(k) % Serie en z
            Z = cos(beta(m+1)*z) + ...
                (hz1/(lambda_z*beta(m+1)))*sin(beta(m+1)*z);
    
            % Résolution en 1D
            gamma = sqrt(1j*w/a_x + alpha(n+1)^2 + beta(m+1)^2);

            A = [lambda_x/(2*e), hx2/2]; % Polinôme en xi
            B = [-lambda_x/(2*e), hx2/2]; % Polinôme en xi
            [P,Q] = padecoef(1,order(k)); % Aprox. e^(x) = P(xi)/Q(xi)
        
            % Aproximation de la fonction de transfert F(xi) = N(xi)/D(xi)
            N = conv(P,Q); 
            D = conv(conv(Q,Q), A) + conv(conv(P,P), B);
        
            % Passe à la variable de Laplace s = (a/e^2)xi
            N = changeVariable(N(mod(fliplr(1:length(N)),2)==1), ...
                [e^2/a_x (alpha(n+1)*e)^2 + (beta(m+1)*e)^2]);
            D = changeVariable(D(mod(fliplr(1:length(D)),2)==1), ...
                [e^2/a_x (alpha(n+1)*e)^2 + (beta(m+1)*e)^2]);
            N = N/D(end); D = D/D(end); % Unicité de F(s) (d0 = 1)
        
            % Diagramme de bode
            Fs_eval = polyval(N,w*1j)./polyval(D,w*1j);

            % Calcule le facteur de correction de la serie int(Y)*int(Z)
            if alpha(n+1) == 0
                int_Y = Ly;
            else
                int_Y = -sin(alpha(n+1)*Ly)/alpha(n+1) + ...
                    (hy1/(alpha(n+1)*lambda_x)) * ...
                    (cos(alpha(n+1)*Ly)/alpha(n+1) - 1/alpha(n+1));
            end
            if beta(m+1) == 0
                int_Z = Lz;
            else
                int_Z = -sin(beta(m+1)*Lz)/beta(m+1) + ...
                    (hz1/(beta(m+1)*lambda_z)) * ...
                    (cos(beta(m+1)*Lz)/beta(m+1) - 1/beta(m+1));
            end

            % Some les fonctions (serie en y et en z)
            Fs_3D_approx = Fs_3D_approx + Fs_eval * ...
                (Y/Nalpha(n+1))*(Z/Mbeta(m+1))*int_Z*int_Y;
        end
    end

    % Plot
    mag_3D_approx = abs(Fs_3D_approx);
    phase_3D_approx = angle(Fs_3D_approx);
    subplot(2,1,1);
    semilogx(w,20*log10(mag_3D_approx), colors(k), LineWidth=1.4, ...
        DisplayName="3D O = "+num2str(order(k)));
    subplot(2,1,2);
    semilogx(w, phase_3D_approx*180/pi, colors(k), LineWidth=1.4);
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
saveas(fig, figDir+"\padeApprox3D.png");
sgtitle({"R\'{e}ponse en fr\'{e}quence de $F(s)$", ...
    "avec l'approximation de pade"}, Interpreter='latex', ...
    FontSize=21);


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