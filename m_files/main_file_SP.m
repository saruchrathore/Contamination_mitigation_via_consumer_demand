%% Approach 2: Shortest path from the contaminated node to the sink node

%% Initialize MATLAB-EPANET toolkit 

start_toolkit();
net = epanet(fileName);

%% Find head constraints using the shorted path algorithm

head_constraints_SP

%% Contamination control simulation

contamination_control_SP

%% Remove path

rmpath(pwd)