% Frequency analysis directory with frequency domain analysis and transfert
% functions approximations.
% Version 2.0 14-08-2023
%
% Pure theorical frequency analysis
%   model_1d                - Analysis of Ff(s) and Fb(s) in 1D
%   model_2d                - Analysis of Ff(s) and Fb(s) in 2D
%   model_3d                - Analysis of Ff(s) and Fb(s) in 3D
% 
% Approximations frequency analysis
%   model_1d_pade           - Pade approximation for 1D model
%   model_1d_taylor         - Taylor approximation for 1D model
%   model_2d_pade           - Pade approximation for 2D model
%   model_2d_taylor         - Taylor approximation for 2D model
%   model_3d_pade           - Pade approximation for 3D model
%   model_3d_taylor         - Taylor approximation for 3D model
%
% Other files
%   main_freqAnalysis       - Do 1D and 2D/3D analysis at once (main file)
%   bisec                   - Bisection method to find functions zeros
%   rep                     - Generates other report figures (secondary)
%   J_roots                 - Roots of Bessel functions of first kind
%   poly                    - Contains all the information for poly class
%
% See also sysDataType, thermalData.