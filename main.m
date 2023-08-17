clc;
%% Main file to all analysis

fprintf("<strong>MAIN FILE ANALYSIS</strong>\n\n");
% Convert the data
run("database\convertData.m");

% Do the frequential analysis
run("freqAnalysis\main_freqAnalysis.m");

% System identification
run("identification\main_identification.m");

% Do the noise test
run("noise\main_noise.m");