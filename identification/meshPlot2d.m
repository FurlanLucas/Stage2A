function meshPlot2d(dataIn, T, Mx, Mr)
    %% meshPlot2d
    %
    % Function to plot the mesh used in two-dimensional analysis.

    %% Inputs

    % Geometry
    dirOut = 'outFig';
    analysisName = dataIn.Name;
    ell = dataIn.sysData.ell;    % [] 
    Rmax = dataIn.sysData.Size;  % [m] Termocouple size
    r0 = dataIn.sysData.ResSize; % [m] Resistance size

    % Discretization
    dx = ell/(Mx-1);
    dr = Rmax/(Mr-1);

    % Other variables
    Mgamma = 30; % Points in gamma direction

    %% Main

    x = (0:Mx-1)*dx;
    r = (0:Mr-1)*dr;
    gamma = linspace(0, 2*pi, Mgamma);    
    
    % Lateral surface
    [X, GAMMA] = meshgrid(x, gamma);
    Y = r(end) .* cos(GAMMA);
    Z = r(end) .* sin(GAMMA);
    T = zeros(size(X));

    fig = figure; hold on;
    mesh(Z*1e3, Y*1e3, X*1e3, T, EdgeColor='k', MarkerSize=5, Marker='o',...
        MarkerFaceColor='k');

    % Base
    [GAMMA, R] = meshgrid(gamma, r);
    Y = R .* cos(GAMMA);
    Z = R .* sin(GAMMA);
    X = ones(size(Z))*x(end);
    T = zeros(size(X));

    mesh(Z*1e3, Y*1e3, X*1e3, T, EdgeColor='k', MarkerSize=5, Marker='o',...
        MarkerFaceColor='k');

    % Final graph configurations;
    axis equal; view(-30.9,26.3682);
    xlabel("X (mm)", Interpreter="latex", FontSize=17);
    ylabel("Y (mm)", Interpreter="latex", FontSize=17);
    zlabel("Z (mm)", Interpreter="latex", FontSize=17);
    saveas(fig, dirOut + "\" + analysisName + "\mesh2D.eps", 'epsc');

end