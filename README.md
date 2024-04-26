# Contamination_impact_mitigation_in_water_distribution_networks_through_consumer_demand_control
This repo contains the code for 'Contamination impact mitigation in water distribution networks through consumer demand control'

Prerequisites:

The code is written in MATLAB and would require the CasADi toolbox (https://web.casadi.org/) to run the simulation tests.
This work also uses the EPANET-Matlab-Toolkit which is a Matlab class for EPANET libraries. Please install the toolkit before use. For more information see https://github.com/OpenWaterAnalytics/EPANET-Matlab-Toolkit#EPANET-MATLAB-Toolkit .

The code also requires the MATLAB: 'Symbolic Math Toolbox' and 'Statistics and Machine Learning Toolbox'. Please install them before running the code.


The code is essentially divided into two parts:
1. Running simulation tests, with different contamination source nodes
2. Presenting summary statistic results based on the saved result data from simulation tests. The results have been stored in 'Result_data'



The 'dependencies' folder contains all the function files, including CasADi and EPANET toolbox, required to run this code. The folder is added to the search path in 'run_contamination_impact_mitigation.m' file.

To run both the part one needs to simply run the 'run_contamination_impact_mitigation.m' file. You will be presented with a prompt to select which part would you like to run.
