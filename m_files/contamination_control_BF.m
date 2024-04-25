%% Define optimization problem for demand control

optimization_problem_BF  % Define the optimization problem

%% Simulation open loop


% Simulation time span
timeStep = 30*60;
simulationDuration = sim_hours*3600;

% Analysis options/settings
net.setTimeSimulationDuration(simulationDuration);
net.setTimeReportingStep(timeStep);
net.setTimeHydraulicStep(timeStep);

net.setTimeQualityStep(timeStep)

sim_time = net.getTimeSimulationDuration/3600; %hours
hyd_step = double(net.getTimeHydraulicStep)/3600; %hours
simSteps = double(sim_time/hyd_step); %steps

%% Set contaminant concentration and a time profile (start and end time)
injection_conc = 40;
injection_start_time = 1;
injection_stop_time = 4;
contam_pat = zeros(1, simSteps); % initialize contamination vector
contam_pat(injection_start_time:injection_stop_time) = 1; % define contam pattern
contam_pat_ind=net.addPattern('P-Contam',contam_pat); % get pattern index

%% Set nodes suspect for contamination

net.setQualityType('CONCEN');
net.setNodeInitialQuality(zeros(1,n_H));
for i=1:n_contaminant
    net.setNodeSourceType(contaminantIDX(i),'MASS');
    net.setNodeSourceQuality(contaminantIDX(i),injection_conc);
    net.setNodeSourcePatternIndex(contaminantIDX(i),contam_pat_ind);
end
net.saveInputFile(net.BinTempfile);

%% Hydraulic simulation

net.openHydraulicAnalysis;
net.initializeHydraulicAnalysis;

net.openQualityAnalysis;
net.initializeQualityAnalysis;

tstep = 1;
nrSteps = ceil(simulationDuration/timeStep)+1;
epa30.t = zeros(1,nrSteps);
epa30.p = zeros(net.getNodeCount,nrSteps);
epa30.q = zeros(net.getLinkCount,nrSteps);
epa30.d = zeros(net.getNodeCount,nrSteps);
epa30.head=zeros(net.getNodeCount,nrSteps);
epa30.nodequality=zeros(net.getNodeCount,nrSteps);
epa30.linkquality=zeros(net.getLinkCount,nrSteps);

% Run the analysis
i = 1;
while (tstep>0)
    t  = net.runHydraulicAnalysis;
    tq = net.runQualityAnalysis;

    epa30.p(:,i)  = net.getNodePressure'*0.098;  % [m --> bar]
    epa30.q(:,i)  = net.getLinkFlows';     % [CMH]
    epa30.t(i)    = t;
    epa30.d(:,i) = net.getNodeActualDemand'; % [CMH]
    epa30.head(:,i) = net.getNodeHydaulicHead';   % [m];
    epa30.nodequality(:,i)=net.getNodeActualQuality;
    epa30.linkquality(:,i)=net.getLinkActualQuality;

    tstep = net.nextHydraulicAnalysisStep;
    tstepq = net.nextQualityAnalysisStep;
    i = i+1;
end
net.closeQualityAnalysis;
net.closeHydraulicAnalysis;


nodal_demand30=epa30.d(dc_index,:);     % Consumer nodal demand in open loop simulation

dc30=-nodal_demand30;

nodal_pressure30=epa30.p;       % Nodal pressure in open loop simulation

nodal_head30=epa30.head;        % Nodal head in open loop simulation

nodal_quality30=epa30.nodequality(dc_index,:);      % Nodal contamination in open loop simulation

link_quality30=epa30.linkquality;      % Link contamination in open loop simulation

%% Replace demand pattern for all the nodes to be 1
% To implement the demand pattern obtained from solving the optimization problem.
% The demand pattern obtained from the optimization problem will be
% multiplied to this new pattern

demand_pattern=net.getPattern;

net.deletePatternAll;

new_pattern=ones(1,size(demand_pattern,2));

net.addPattern('one_pattern',new_pattern);

patternIndices = net.getNodeDemandPatternIndex{1};
patternIndices_new = patternIndices + 1;
net.setNodeDemandPatternIndex(patternIndices_new);
patternIndices = net.getNodeDemandPatternIndex{1};

demand_pattern_new=net.getPattern;



%% Empty arrays for data storing

N=size(dc30,2);

pnHeadCon_all=zeros(num_sup,N);
dcCon_all=zeros(num_con,N);

qCCon_all=zeros(n_chords,N);
qTCon_all=zeros(m_H-n_chords,N);
p_barCon_all=zeros(n_H-1,N);

pt_setpoint=3.5;


reservoir_idx=net.getNodeReservoirIndex;

%% Set contaminant concentration and a time profile (start and end time)

contam_pat_ind=net.addPattern('P-Contam',contam_pat); % get pattern index

%% Set nodes suspect for contamination

net.setQualityType('CONCEN');
net.setNodeInitialQuality(zeros(1,n_H));
for i=1:n_contaminant
    net.setNodeSourceType(contaminantIDX(i),'MASS');
    net.setNodeSourceQuality(contaminantIDX(i),injection_conc);
    net.setNodeSourcePatternIndex(contaminantIDX(i),contam_pat_ind);
end
net.saveInputFile(net.BinTempfile);


%% Controlled simulation

net.openHydraulicAnalysis;
net.initializeHydraulicAnalysis;

net.openQualityAnalysis;
net.initializeQualityAnalysis;


tstep = 1;
nrSteps = ceil(simulationDuration/timeStep)+1;
epacon.t = zeros(1,nrSteps);
epacon.p = zeros(net.getNodeCount,nrSteps);
epacon.q = zeros(net.getLinkCount,nrSteps);
epacon.d = zeros(net.getNodeCount,nrSteps);
epacon.head=zeros(net.getNodeCount,nrSteps);
epacon.nodequality=zeros(net.getNodeCount,nrSteps);
epacon.linkquality=zeros(net.getLinkCount,nrSteps);

%% Control simulation

% Run the analysis
i = 1;

while (tstep>0)


    opti2.set_value(dcOrig_par,dc30(:,i));      % Set original demand value in the optimization problem
    opti2.set_value(ptDes_par,pt_setpoint);      % Set desired reference pressure setpoint in optimization problem
    opti2.set_initial(dcCon_var,dc30(:,i));
    
    % Solve optimization problem

    sol2 = opti2.solve();

    dc_con= sol2.value(dcCon_var);
    pSupHead_con=sol2.value(pSupCon_var);

    pbar_con=sol2.value(p_barCon_var);

    % Store data

    dcCon_all(:,i)=dc_con;
    pnHeadCon_all(:,i)=pSupHead_con;
    p_barCon_all(:,i)=pbar_con;

    con_demand_EPANET=-dc_con;
    con_PnHead_EPANET=pSupHead_con/0.098;     % [bar --> m]

    net.setNodeBaseDemands(con_demand_EPANET);
    net.setNodeElevations(dp_index, con_PnHead_EPANET);

    t  = net.runHydraulicAnalysis;
    tq = net.runQualityAnalysis;

    epacon.p(:,i)  = net.getNodePressure'*0.098;  % [m --> bar]
    epacon.q(:,i)  = net.getLinkFlows';
    epacon.t(i)    = t;
    epacon.d(:,i) = net.getNodeActualDemand';
    epacon.head(:,i) = net.getNodeHydaulicHead'; % [m];
    epacon.nodequality(:,i)=net.getNodeActualQuality;
    epacon.linkquality(:,i)=net.getLinkActualQuality;

    tstep = net.nextHydraulicAnalysisStep;
    tstepq = net.nextQualityAnalysisStep;
    i = i+1;
end

net.closeQualityAnalysis;
net.closeHydraulicAnalysis;


nodal_demand_con=epacon.d(dc_index,:);      % Consumer nodal demands in controlled simulation

nodal_pressure_con=epacon.p;    % Nodal pressure in controlled simulation

nodal_head_con=epacon.head;     % Nodal head in controlled simulation

nodal_quality_con=epacon.nodequality(dc_index,:);     % Nodal contamination in controlled simulation

link_quality_con=epacon.linkquality;     % Link contamination in controlled simulation