%% Optimization problem

opti2 = casadi.Opti();

%% Variables

rho_fluid=997;  % [kg/m^3] Density of water
gav=9.81;      % [m/s^2] Gravitational constant

u_min=0;
u_max=80;                        % [m^3/h] Max flow from supply station
pp_min=3;
pp_max=6;                  % [bar] Max pressure from supply station

p_min=2.5;

flush_max=10;       % [m^3/h] Max flow from the flushing location
flush_min=4;       % [m^3/h] Max flow from the flushing location
%% Casadi variables

p_allCon_var=opti2.variable(n_H,1);     % Create variables for pressure at all nodes

% True decision variables

pSupCon_var=p_allCon_var(dp_index);     % Extract variables for pressure at supply node

pnCon_var=p_allCon_var(ref_node);       %  Extract variables for pressure at reference node

ptCon_var=p_allCon_var(target_node);       %  Extract variables for pressure at target node

dCon_var=opti2.variable(n_H,1);         % Create variables for demand at all nodes

dcCon_var=dCon_var(dc_index);           % Extract variables for demand at consumer node

dSupCon_var=dCon_var(dp_index);         % Extract variables for demand at supply node (supply flow)


% Multiple shooting decision variables

p_barCon_var=p_allCon_var(non_ref_nodes,1);     % Extract variables for pressure at non-reference node

qCon_var=opti2.variable(m_H,1);     % Create variables for flow in the edges

qTCon_var=qCon_var(edge_tree);      % Extract variables for flow in the tree edges
qCCon_var=qCon_var(set_chord);      % Extract variables for flow in the chrod edges

% Parameters of the optimization problem

dcOrig_par=opti2.parameter(num_con,1);      % Original consumer demand
ptDes_par=opti2.parameter(1,1);             % Desired set-point pressure at the reference node


dc_index_ExSink=setdiff(dc_index,sinkIDX);
%% Objective 

% 1. Minimize the difference between the original and the optimized consumer
% demand. 

obj1=(dcOrig_par(dc_index_ExSink)-dcCon_var(dc_index_ExSink))'*(dcOrig_par(dc_index_ExSink)-dcCon_var(dc_index_ExSink));

% 2. Get the desired reference node pressure

obj2= (ptDes_par-ptCon_var)^2;

% 3. Maximize the pressure difference between the contamination source node
% and the sink node

obj3=-((p_allCon_var(contaminantIDX,1)-ones(n_contaminant,1)*p_allCon_var(sinkIDX,1))'*(p_allCon_var(contaminantIDX,1)-ones(n_contaminant,1)*p_allCon_var(sinkIDX,1)));

objCon=obj1+obj2+500*obj3;

%% Constratints

% Network flow equations (constraints)
lambda_qCon_var=lambda.*abs(qCon_var).*qCon_var;

% lambda_qCon_var=lambda.*(qCon_var.^1.8);

st_1Con=B*lambda_qCon_var;
st_2Con=-inv(H_T_bar)*H_C_bar*qCCon_var+inv(H_T_bar)*dCon_var(non_ref_nodes);

opti2.subject_to(st_1Con==0);
opti2.subject_to(qTCon_var==st_2Con);

% Network pressure equation (constraint)
st_3Con=inv(H_T_bar')*lambda_qCon_var(edge_tree)-(z_bar-ones(n_H-1,1)*z_n)+ones(n_H-1,1)*pnCon_var;
    
opti2.subject_to(p_barCon_var==st_3Con);

% Physical constraint

opti2.subject_to(pp_min<=pSupCon_var);
opti2.subject_to(pSupCon_var<=pp_max);

opti2.subject_to(u_min<=dSupCon_var);
opti2.subject_to(dSupCon_var<=u_max);

% Pressure head constraint

pT=sym('pT',[n_H 1],'real');

% con_count=0;

% Inner level

Con_inner=[];

for i=1:length(inner_level)-1

    for j=1:length(inner_level{i,1})

    Con_inner=[Con_inner;pT(inner_level{i,1}(j,1))>pT(inner_level{i+1,1})];

    opti2.subject_to((p_allCon_var(inner_level{i,1}(j,1))+z(inner_level{i,1}(j,1)))>(p_allCon_var(inner_level{i+1,1})+z(inner_level{i+1,1})));
    end
end

% Outer level

Con_outer=[];

for i=1:length(outer_level)

    try
    Con_outer=[Con_outer;pT(outer_level{i,1}(1,1))<pT(outer_level{i,1}(2,:))];

    opti2.subject_to((p_allCon_var(outer_level{i,1}(1,1))+z(outer_level{i,1}(1,1)))<(p_allCon_var(outer_level{i,1}(2,:))+z(outer_level{i,1}(2,:))));
    end
end


opti2.subject_to(dCon_var(dc_index_ExSink)>=dcOrig_par(dc_index_ExSink));
opti2.subject_to(dcCon_var(dc_index_ExSink)<=(1-demand_regulation)*dcOrig_par(dc_index_ExSink));

% Constraint on the flushing flow

opti2.subject_to(-flush_min>=dCon_var(sinkIDX));
opti2.subject_to(dCon_var(sinkIDX)>=-flush_max);

% Negative pressure constraint

opti2.subject_to(p_min<=p_allCon_var);

% Mass conservation

opti2.subject_to(sum(dCon_var)==0);

%% Solver

optsCon=struct;
optsCon.ipopt.print_level=0;
optsCon.print_time=0;
optsCon.ipopt.max_iter=1e4;

opti2.solver('ipopt',optsCon);


opti2.minimize(objCon);

