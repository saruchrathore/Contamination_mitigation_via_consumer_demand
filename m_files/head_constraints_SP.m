%% Create MATLAB graph from the incidence matrix

% Find the source nodes from incidence matrix
[st_n,~] = find(H == -1 );

% Find the target nodes from incidence matrix
[end_n,~] = find(H == 1 );

weights = net.getLinkLength';

gra = graph(st_n,end_n,weights);


%% Shortest path

P=shortestpath(gra,contaminantIDX,sinkIDX);

%% Levels

% Levels for the path nodes (inner layer)

inner_level=cell(length(P),1);

innerAllNode=P;
inner_level{1,1}=contaminantIDX;

for i=2:length(P)-1

inter_adjNode_temp=neighbors(gra,P(i))';

inter_adjNode_temp=setdiff(inter_adjNode_temp,innerAllNode);

innerAllNode=[innerAllNode inter_adjNode_temp];

innerLevel_temp=[P(i); inter_adjNode_temp'];

inner_level{i,1}=innerLevel_temp;
end

inner_level{end,1}=sinkIDX;

innerAllNode_ordered=cell2mat(inner_level)';

% Outer layer

outer_level=cell(length(innerAllNode_ordered),1);
outerAllNode=innerAllNode_ordered;

for i=1:length(innerAllNode_ordered)

    outer_adjNode_temp=neighbors(gra,innerAllNode_ordered(i))';

    outer_adjNode_temp=setdiff(outer_adjNode_temp,outerAllNode);

    outerLevel_temp=[innerAllNode_ordered(i) zeros(1,length(outer_adjNode_temp)-1); outer_adjNode_temp];

    outer_level{i,1}=outerLevel_temp;

end

%% Plotting pressure head colourbar

%Extract all sink nodes for plot and define a Graph only for these nodes
GraphNoSinks = Graph;
numSinks=1:length(sinksIDX);
GraphNoSinks = rmnode(GraphNoSinks,sinksIDX);
NoSinksID = net.getNodeNameID;
NoSinksID(sinksIDX) = [];
NoSinksidx = net.getNodeIndex(NoSinksID);
GraphSinks = Graph;
GraphSinks = rmnode(GraphSinks,NoSinksidx);

%Extract the selected sink node for plot and define a Graph only for these nodes

Sinkremove = net.getNodeNameID;
Sinkremove(sinkIDX) = [];
GraphSink = Graph;
GraphSink = rmnode(GraphSink,Sinkremove);

%Extract leakage node for plot and define a Graph only for this node
RemoveLeak = net.getNodeNameID;
numContaminant=1:length(contaminantIDX);
RemoveLeak(contaminantIDX) = [];
Graphcont = Graph;
Graphcont = rmnode(Graphcont,RemoveLeak);

%Extract inlets nodes for plot and define a Graph only for these nodes
inlets = dp_index;
numinlets = 1:length(inlets);
Inletsremove = net.getNodeNameID;
Inletsremove(inlets) = [];
GraphInlets = Graph;
GraphInlets = rmnode(GraphInlets,Inletsremove);


% Pressure values

psi_level=flip(linspace(0.4,1,size(inner_level,1)+1));

% Assign pressure head values

% Inner level
psibar=zeros(n_H,2);

for i=1:size(inner_level,1)

    val=psi_level(i+1);
    psibar(inner_level{i,1},1)=val;
    psibar(inner_level{i,1},2)=i+1;

end

% Outer level

for i=size(outer_level,1):-1:1

    in_IDX=psibar(outer_level{i,1}(1,1),2);

    val=psi_level(in_IDX-1);
    try
        psibar(outer_level{i,1}(2,:),2)=in_IDX-1;
        psibar(outer_level{i,1}(2,:),1)=val;
    end
end

fig = generateGraphpaper(psibar(:,1), Graph, GraphSinks, Graphcont, GraphInlets, numSinks,numinlets,numContaminant,sinksIDX,contaminantIDX,net);

