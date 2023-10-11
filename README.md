# Caractérisation et identification de capteurs de flux en conditions extrêmes  

Work presented at ENSEIRB-MATMECA in the Institut National Polytechinique de Bordeaux as a second-year internship, carried out at the Laboratoire de l’Intégration du Matériau au Système (IMS) and Institut de mécanique et d’ingénierie (I2M).

Author: Lucas Furlan Supervisors: Stéphane Victor, Jean-Luc Battaglia and Andrzej Kusiak.

## Introduction

This repository contains all matlab files used during the thermal analysis of a thermocouple and its coupled system. It includes:

* Solution for heat equation in frequency domain for one-dimensional and two-dimensional models;
* One-dimensional and two-dimensional axisymmetric finite difference method;
* Polynomial class implementation.

The files are divided into four different main subdirectories for each analysis. The `database` contains the raw data in TXT files and also the equivalent in MAT files (matlab variables). They are saved as a thermalData class, which is defined in `myClasses` directory, as well as other class definitions. All functions have their own help context implementation, meaning that the command `help functionName` will display its description. It also works with directories, for instance `help freqAnalysis` displays its structure with some instructions. Finally, the output figures are saved in `outFig`, which is generated in the first code execution and can be changed in `analysisSettings.m` file.

## Files

### Frequential analysis

The `freqAnalysis` directory presents files used to generate the frequency response of all models, including their polynomial approximations. The file also generates some TEX files for reporting and 

### Theoretical comparison

Files for theoretical comparison using analytical and numerical models. Contains the three finite difference methods implemented and the convergence of numerical methods.

### Identification

Sets of all functions used to identify the system parameters, including model convergence, model delay convergence and model inversion. The convergence is analyzed for four different noise structures: OE, ARX, ARMAX and BJ, using the *system identification toolbox*. Uses a minimum phase filter approximation and an optimization of future time step prediction to estimate the heat flux.

### Input indentification

Input identification for reentry data. Uses the reentry heat flux data as a reference to generate a tension input to the power source. 

### Noise

Analyze the noise in the data using an oscilloscope and DAS acquired data.




