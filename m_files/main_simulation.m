% Note: Flushing node and sink node are used interchangeably in the
% comments.

prompt = ['Specify the contamination source node index x.',...
    '\nYou can specify single or multiple nodes.',...
    '\nTo specify multiple nodes use [x y z] format:    '];

consIDX=input(prompt);    % Specify the contamination source index

% Run simulation for each contamination source node individually

for III=1:length(consIDX)

    clearvars -except consIDX III

    contaminantIDX=consIDX(III);    % select the contamination source node 'i'

    %% Initialize MATLAB-EPANET toolkit and get incidence matrix and other network parameters

%     start_toolkit();
    fileName = 'CY_DMA2.inp';   % Insert name of EPANET .INP
    dispname='CY_DMA2';
    net = epanet(fileName);

    % Supply nodes

    Supply_ID={'R-1';'R-2'};

    % Select reference node
    refNodeID = 'R-2';

    % Get graph matrices
    [H,H_C_bar,H_T_bar,Graph,T,edge_tree,set_chord,H_bar,H_T,H_C,ref_node,non_ref_nodes] = create_incidence(net,refNodeID);

    n_H=size(H,1);
    m_H=size(H,2);

    n_chords=length(set_chord);

    % Get name ID for the junctions and the pipes
    node_name=net.getNodeNameID;
    link_name=net.getLinkNameID;



    % Get indices for the supply nodes and the consumer nodes
    dp_index=double(net.getNodeIndex(Supply_ID));
    dc_index=setdiff(1:n_H,dp_index);     % Nodes connected to the consumers

    num_non_refs = n_H - 1;
    num_con= size(dc_index,2);
    num_sup=size(dp_index,2);

    % Get units of EPANET model

    net_units=net.getUnits;

    % Get elevation of each node
    height_node= net.getNodeElevations';
    height_node(dp_index)=0;

    % Get pipe parameters
    length_pipe=  net.getLinkLength';
    diameter_pipe=  net.getLinkDiameter';
    % epsilon=  ones(size(H,2),1)*0.05e-03;

    % Correct units to meters
    switch net_units.NodeElevationUnits

        case 'meters'
            height_node; % [m --> m]

        case 'feet'
            height_node= height_node*0.3048; % [ft. --> m]

        otherwise
            error('Unknown Elevation unit')

    end

    switch net_units.LinkLengthsUnits

        case 'meters'
            length_pipe; % [m --> m]

        case 'feet'
            length_pipe= length_pipe*0.3048; % [ft. --> m]

        otherwise
            error('Unknown Link Length unit')

    end

    switch net_units.LinkPipeDiameterUnits

        case 'millimeters'
            diameter_pipe=diameter_pipe/1000; % [mm --> m]

        case 'inch'
            diameter_pipe= diameter_pipe*0.0254; % [ft. --> m]

        otherwise
            error('Unknown Link Diameter unit')

    end

    switch net_units.LinkPipeRoughnessCoeffUnits

        case 'mm(Darcy-Weisbach), unitless otherwise'
            epsilon=  net.getLinkRoughnessCoeff/1000; % [mm --> m]

        otherwise
            epsilon=  ones(size(H,2),1)*0.05e-03;

    end

    % 6. Reynolds number

    R=10000;    % [] Reynolds number

    % 7. Density of fluid

    rho_fluid=997;  % [kg/m^3] Density of water


    % 8. Gravitational acceleration

    g=9.81;      % [m/s^2] Gravitational constant


    % Contaminant Source and Sink nodes

    D = nodeTopologicalDistance(fileName,dispname); % minimum topological distance between all nodes

    % Flushing nodes
    sinksIDX=[1 11 15 21 24 35 43 46 48 51 59 68 71 75 82 90];
%     sinksIDX=[35];
    plotting_Sinks

    % Traget node
    target_node=51;

    % Simulation duration and threshold for contamination
    sim_hours=2*24;
    con_thres=1e-2;

    %% Creating Model of the network

    % Create network parameter variables for the graph theory based model
    network_parameters


    %% Allocate space for different result variables

    clearvars -except set_chord edge_tree non_ref_nodes ref_node m_H n_H  H_T_bar rho_fluid g ...
        dc_index dc_sym H_C_bar dc_index lambda F H B H_T z_bar z_n z node_name_graph dp_index...
        n_chords num_non_refs num_con num_sup node_name link_name contaminantIDX sinksIDX...
        fileName n_contaminant consIDX Graph target_node sim_hours con_thres

    sz = [length(sinksIDX) 15];
    varTypes = {'double','double','double','double','double','double','double','double','double','double','double','double','double','double','double'};
    varNames = {'Sink Node','Nominal contaminated water consumed [m3]','BF contaminated water consumed [m3]','SP contaminated water consumed [m3]','Contaminated water flushed from sink node (BF) [m3]','Contaminated water flushed from sink node (SP) [m3]',...
        'Nominal time for contaminant free network','BF time for contaminant free network','SP time for contaminant free network','Change in consumption(BF) [m3]','Percentage change(BF)','Change in consumption(SP) [m3]','Percentage change(SP)','BF_sim_time','SP_sim_time'};
    results = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    results(:,:)={NaN};

    sz = [length(sinksIDX) 3];
    varTypes = {'double','string','string'};
    varNames = {'Sink Node','Identifier','Message'};

    Error_msgs_BF = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    Error_msgs_SP = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);


    %% Run simulations with different flushing nodes

    for I_sink=1:length(sinksIDX)

        % Select flushing node 'i'
        sinkIDX=sinksIDX(I_sink);
        results(I_sink,1)={sinkIDX};

        % Try to run the control framework with the breadth-first search
        % approach. If it fails, store the error.
        try
            tic
            %% Run contamination flushing with BF search approach

            main_file_BF

            %% Results

            % Water consumption results. Change in conspumtion

            nodal_consumption=sum(nodal_demand30(:,1:2*sim_hours),2)*0.5;            % Nodal consumption
            nodal_consumption_BF=sum(nodal_demand_con(:,1:2*sim_hours),2)*0.5;


            water_consumption=sum(nodal_consumption);           % Total consumption
            water_consumption_BF=sum(nodal_consumption_BF);

            change_consumption_BF=water_consumption-water_consumption_BF+nodal_consumption_BF(sinkIDX);
            change_percentage_BF=change_consumption_BF*100/water_consumption;

            % Contaminated water flushed, and contaminated water at the
            % nodes ad in the pipes

            contaminant_nodes_BF=double(nodal_quality_con(:,1:2*sim_hours)>con_thres);    % Contaminated nodes

            contaminant_links_BF=double(link_quality_con(:,1:2*sim_hours)>con_thres);    % Contaminated link

            nodal_consumption_BF_30min=nodal_demand_con(:,1:2*sim_hours)*0.5*1000;  % in Liters
            nodal_contaminant_BF=sum(nodal_consumption_BF_30min.*nodal_quality_con(:,1:2*sim_hours),2);

            contaminated_flushed_BF=sum(contaminant_nodes_BF(sinkIDX,:).*nodal_demand_con(sinkIDX,1:2*sim_hours)*0.5);   % Contaminanted water flushed

            % Flushing time results

            con_node_BF=sum(contaminant_nodes_BF);
            time_nodeflushed_BF=find(con_node_BF,1,'last')+1;

            con_link_BF=sum(contaminant_links_BF);
            time_linkflushed_BF=find(con_link_BF,1,'last')+1;
            time_linkflushed_BF(isempty(time_linkflushed_BF))=1;

            time_flushed_BF=max(time_nodeflushed_BF,time_linkflushed_BF);

            if time_flushed_BF>2*sim_hours
                time_flushed_BF=Inf;
            end

            % Contaminanted water consumed

            contaminant_nodes_BF_wo=contaminant_nodes_BF;
            contaminant_nodes_BF_wo(sinkIDX,:)=zeros(1,2*sim_hours);
            contaminant_water_BF_wo=sum(sum(contaminant_nodes_BF_wo.*nodal_demand_con(:,1:2*sim_hours)*0.5));

            sim_time=toc;

            % Store results
            results(I_sink,3)={contaminant_water_BF_wo};
            results(I_sink,5)={contaminated_flushed_BF};
            results(I_sink,8)={time_flushed_BF};
            results(I_sink,10)={change_consumption_BF};
            results(I_sink,11)={change_percentage_BF};
            results(I_sink,14)={sim_time};

        catch ME

            cprintf ('UnterminatedStrings',['Error with BF algorithm in sink node ', num2str(sinkIDX),'\n'])

            Error_msgs_BF(I_sink,1)={sinkIDX};
            Error_msgs_BF(I_sink,2)={ME.identifier};
            Error_msgs_BF(I_sink,3)={ME.message};

        end

        % Try to run the control framework with the shortest path
        % approach. If it fails, store the error.
        try

            %% Run contamination flushing with SP algorithm

            tic
            main_file_SP

            %% Results

            % Water consumption results. Change in conspumtion

            nodal_consumption=sum(nodal_demand30(:,1:2*sim_hours),2)*0.5;    % Nodal consumption

            nodal_consumption_30min_L=nodal_demand30(:,1:2*sim_hours)*0.5*1000;        % in Litre
            nodal_contaminant=sum(nodal_consumption_30min_L.*nodal_quality30(:,1:2*sim_hours),2);

            nodal_consumption_SP=sum(nodal_demand_con(:,1:2*sim_hours),2)*0.5;


            water_consumption=sum(nodal_consumption);       % Total consumption

            water_consumption_SP=sum(nodal_consumption_SP);
            change_consumption_SP=water_consumption-water_consumption_SP+nodal_consumption_SP(sinkIDX);

            change_percentage_SP=change_consumption_SP*100/water_consumption;

            % Contaminated water flushed, and contaminated water at the
            % nodes ad in the pipes

            nodal_consumption_SP_30min=nodal_demand_con(:,1:2*sim_hours)*0.5*1000;  % in Liters
            nodal_contaminant_SP=sum(nodal_consumption_SP_30min.*nodal_quality_con(:,1:2*sim_hours),2);

            contaminant_nodes=double(nodal_quality30(:,1:2*sim_hours)>con_thres);         % Contaminated node
            contaminant_links=double(link_quality30(:,1:2*sim_hours)>con_thres);    % Contaminated link

            contaminant_nodes_SP=double(nodal_quality_con(:,1:2*sim_hours)>con_thres);
            contaminant_links_SP=double(link_quality_con(:,1:2*sim_hours)>con_thres);    % Contaminated link

            contaminated_flushed_SP=sum(contaminant_nodes_SP(sinkIDX,:).*nodal_demand_con(sinkIDX,1:2*sim_hours)*0.5);

            % Flushing time results


            con_node=sum(contaminant_nodes);
            time_nodeflushed=find(con_node,1,'last')+1;

            con_link=sum(contaminant_links);
            time_linkflushed=find(con_link,1,'last')+1;

            time_flushed=max(time_nodeflushed,time_linkflushed);

            if time_flushed>2*sim_hours
                time_flushed=Inf;
            end

            con_node_SP=sum(contaminant_nodes_SP);
            time_nodeflushed_SP=find(con_node_SP,1,'last')+1;

            con_link_SP=sum(contaminant_links_SP);
            time_linkflushed_SP=find(con_link_SP,1,'last')+1;
            time_linkflushed_SP(isempty(time_linkflushed_SP))=1;

            time_flushed_SP=max(time_nodeflushed_SP,time_linkflushed_SP);

            if time_flushed_SP>2*sim_hours
                time_flushed_SP=Inf;
            end

            % Contaminanted water consumed

            contaminant_water=sum(sum(contaminant_nodes.*nodal_demand30(:,1:2*sim_hours)*0.5));

            contaminant_nodes_SP_wo=contaminant_nodes_SP;
            contaminant_nodes_SP_wo(sinkIDX,:)=zeros(1,2*sim_hours);
            contaminant_water_SP_wo=sum(sum(contaminant_nodes_SP_wo.*nodal_demand_con(:,1:2*sim_hours)*0.5));

            sim_time=toc;

            % Store results

            results(I_sink,2)={contaminant_water};
            results(I_sink,4)={contaminant_water_SP_wo};
            results(I_sink,6)={contaminated_flushed_SP};
            results(I_sink,7)={time_flushed};
            results(I_sink,9)={time_flushed_SP};
            results(I_sink,12)={change_consumption_SP};
            results(I_sink,13)={change_percentage_SP};
            results(I_sink,15)={sim_time};

        catch ME

            cprintf ('UnterminatedStrings',['Error with SP algorithm in sink node ', num2str(sinkIDX),'\n'])

            Error_msgs_SP(I_sink,1)={sinkIDX};
            Error_msgs_SP(I_sink,2)={ME.identifier};
            Error_msgs_SP(I_sink,3)={ME.message};
        end
    end

    %% Remove path

%     rmpath(pwd)

    %% Save results

    cd new_results
    file_str=['Node',num2str(contaminantIDX),'_vn.mat'];
    save(file_str,'results','Error_msgs_BF','Error_msgs_SP')
    cd ..

end