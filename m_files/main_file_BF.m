%% Approach 1: Breath first search

%% Initialize MATLAB-EPANET toolkit 

start_toolkit();
net = epanet(fileName);

%% Find head constraints using the bf search

head_constraints_BF

%% Contamination control simulation

contamination_control_BF

%% Remove path

rmpath(pwd)