%% Plotting

%Extract all sink nodes for plot and define a Graph only for these nodes
GraphNoSinks = Graph;
numSinks=1:length(sinksIDX);
GraphNoSinks = rmnode(GraphNoSinks,sinksIDX);
NoSinksID = net.getNodeNameID;
NoSinksID(sinksIDX) = [];
NoSinksidx = net.getNodeIndex(NoSinksID);
GraphSinks = Graph;
GraphSinks = rmnode(GraphSinks,NoSinksidx);

%Extract contamination source node for plot and define a Graph only for
%these nodes
RemoveCont = net.getNodeNameID;
numContaminant=1:length(contaminantIDX);
RemoveCont(contaminantIDX) = [];
GraphCont = Graph;
GraphCont = rmnode(GraphCont,RemoveCont);

%Extract inlets nodes for plot and define a Graph only for these nodes
inlets = dp_index;
numinlets = 1:length(inlets);
Inletsremove = net.getNodeNameID;
Inletsremove(inlets) = [];
GraphInlets = Graph;
GraphInlets = rmnode(GraphInlets,Inletsremove);


fig = generateSinksGraph(Graph, GraphSinks,GraphInlets,GraphCont,numSinks,numinlets,numContaminant,sinksIDX,contaminantIDX,net);