% Frequency analysis directory with frequency domain analysis and transfert
% functions approximations.
% Version 3.0 01-08-2023
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
% Compare analysis (figure generation)
%   compareh_1d             - Compare tf for different h
%   comparePade_1d          - Compare the Pade approximations in 1D
%   compareTaylor_1d        - Compare the Taylor approximations in 1D
%   comparePadeTaylor       - Compare the Taylor and Pade analysis
%   compare_1d2d            - Compare the 1D and 2D analysis
%   comparePade_2d          - Compare the Pade approximations in 2D
%   compareTaylor_2d        - Compare the Taylor approximations in 2D
%
% Repport
%   eigenValueRoots         - Shows the grph of eigen value roots
%   table2tex               - Creates the tex tables for the repport
%   tf2tex                  - Creates a tex equation using a tf as input
%
% Other files
%   main_freqAnalysis       - Do 1D and 2D/3D analysis at once (main file)
%   bisec                   - Bisection method to find functions zeros
%   J_roots                 - Roots of Bessel functions of first kind
%   mypoly                  - Contains all the information for poly class
%   outFig                  - Output figure directory
%   texOut                  - Output tex files directory
%
% See also sysDataType, thermalData.