% This code provides a summary statistics results considering the most
% efficient node for flushing for all the possible contamination source
% node individually

% The summary statistic results are based on data already obtained from the
% simulation tests considering all the possible contamination source
% nodes individually


%% Weights for the selection of the most efficient flushing node

W_contchange=1;     % Weight on the percentage changes in contaminated water consumption
W_time=0.2;         % Weight on the percentage change in the time until the network is contaminant-free
W_conchange=0.7;    % Weight on the percentage change in consumption


%% Selection of the flushing node

node_number=1:90;       % Total number of nodes

sinksIDX=[1 11 15 21 24 35 43 46 48 51 59 68 71 75 82 90];  % Sink nodes

contamination_node=setdiff(node_number,sinksIDX);   % Contamination source cannot be a sink node

% It is not possible to direct the flow from a leaf node to a sink node.
% Therefore contamination source at the leaf nodes are not considered.
load('leaf_nodes.mat')
contamination_node=setdiff(contamination_node,singleEntryRows);

% Space allocation for the storing the results for the most efficient
% flushing node
BF_best=zeros(length(contamination_node),6);
SP_best=zeros(length(contamination_node),6);

% Selection of the most efficient flushing node and storing the results
for i=1:length(contamination_node)

    current_node=contamination_node(i);     % Contamination source node 'i'

    % Load result data for contamination source node
    cd ..\Result_data
    file_name=['Node',num2str(contamination_node(i)),'_v8.mat'];
    load(file_name)%,'results')
    result_array=table2array(results);
    cd ..\M_files

    % Extract results for the nominal condition
    nominal_data=result_array(:,[2 7]);
    nom_row = find(all(~isnan(nominal_data), 2),1);
    nominal_data=nominal_data(nom_row,:);

    % Extract results for the breadth-first search approach

    BF_data=result_array(:,[1 3 5 8 11]);
    BF_data = BF_data(all(~isnan(BF_data), 2), :);
    % Convert the result value to change in percentage
    BF_data_percentage=BF_data;
    BF_data_percentage(:,2)=(nominal_data(1,1)-BF_data(:,2))*100/nominal_data(1,1);
    BF_data_percentage(:,4)=(nominal_data(1,2)-BF_data(:,4))*100/nominal_data(1,2);
    % Select the most efficient flushing node and store the result
    best_row=best_sink(BF_data_percentage,W_contchange,W_time,W_conchange);
    BF_best(i,:)=[current_node BF_data_percentage(best_row,:)];

    % Extract results for the shortest path approach

    SP_data=result_array(:,[1 4 6 9 13]);
    SP_data = SP_data(all(~isnan(SP_data), 2), :);
    % Convert the result value to change in percentage
    SP_data_percentage=SP_data;
    SP_data_percentage(:,2)=(nominal_data(1,1)-SP_data(:,2))*100/nominal_data(1,1);
    SP_data_percentage(:,4)=(nominal_data(1,2)-SP_data(:,4))*100/nominal_data(1,2);
    % Select the most efficient flushing node and store the result
    best_row=best_sink(SP_data_percentage,W_contchange,W_time,W_conchange);
    SP_best(i,:)=[current_node SP_data_percentage(best_row,:)];

end

%% Plotting the summary statistics results using box plots

set(0, 'DefaultLineLineWidth',2);
set(0, 'DefaultaxesLineWidth',1);
set(0, 'DefaultaxesFontSize',12);
set(0, 'DefaultTextFontSize',12);
set(0, 'DefaultAxesFontName','Times');

% Box plot for percentage change in the contaminated water consumed
figure
boxplot([BF_best(:,3) SP_best(:,3)],'Labels',{'Breadth-first search','Shortest path'})
xlabel('Pressure constraint identification approaches');ylabel('Percentage change')
title('Percentage change in the contaminated water consumed');

% Box plot for percentage change in the time until the network is
% contaminant-free
figure
boxplot([BF_best(:,5) SP_best(:,5)],'Labels',{'Breadth-first search','Shortest path'})
xlabel('Pressure constraint identification approaches');ylabel('Percentage change')
title('Percentage change in the time until the network is contaminant-free');

% Box plot for percentage change in the consumption
figure
boxplot([BF_best(:,6) SP_best(:,6)],'Labels',{'Breadth-first search','Shortest path'})
xlabel('Pressure constraint identification approaches');ylabel('Percentage change')
title('Percentage change in the consumption')