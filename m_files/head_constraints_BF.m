%% Create MATLAB graph from the incidence matrix

% Find the source nodes from incidence matrix
[st_n,~] = find(H == -1 );

% Find the target nodes from incidence matrix
[end_n,~] = find(H == 1 );
edgeNr = 1:size(H,2);

gra = graph( end_n, st_n);

%% Breadth first search for finding the node pressure head gradients

events = {'discovernode','finishnode'};
vv=bfsearch(gra,sinkIDX,events);    % Breadth first search

Nodesall=vv.Node;
Nodeevent=vv.Event;

newmat=zeros(2,n_H);
newmat(1,1)=Nodesall(1);

i=2;
while Nodeevent(i)~='finishnode'
    newmat(2,i-1)=Nodesall(i);
    i=i+1;
end

% Remove zero rows
newmat( all(~newmat,2), : ) = [];
% Remove zero columns
newmat( :, all(~newmat,1) ) = [];

% Create levels of pressure constraints from the breadth first search output
head_level_method_BF

n_contaminant=1; % Number of contamination source node
contaminantIDXT=contaminantIDX';
CONBranch=NaN(n_contaminant,1);
CONRow=NaN(n_contaminant,1);

contaminantBranch=table(contaminantIDXT,CONBranch,CONRow);

for i=1:n_contaminant

    if ismember(contaminantIDX(i),sinkIDX)

        contaminantBranch.CONBranch(i)=0;

    else
        j=1;
        while isnan(contaminantBranch.CONBranch(i))

            if j>num_adj_nodes
                error('Contaminated node could not be found in any branch')
            end

            if ismember(contaminantIDX(i),branch_cell{j,1})

                contaminantBranch.CONBranch(i)=j;

                [r_branch,~]=find(branch_cell{j,1}==contaminantIDX(i));
                contaminantBranch.CONRow(i)=r_branch;
            end
            j=j+1;
        end

    end

end

branch_level=zeros(1,num_adj_nodes);

pre_ultimate_level=[];

for i=1:num_adj_nodes
    temp_table=contaminantBranch(contaminantBranch.CONBranch==i,:);

    if ~isempty(temp_table)
        branch_level(1,i)=max(temp_table.CONRow);
        temp_amend=[];
        try
            temp_amend= branch_cell{i,1}(1:branch_level(1,i)+1,:);
        catch
            warning('Contaminant node is at the last row')
            temp_amend= branch_cell{i,1}(1:branch_level(1,i),:);
        end

        [r1 c1]=size(pre_ultimate_level);
        [r2 c2]=size(temp_amend);

        if r1<r2
            pre_ultimate_level=[pre_ultimate_level; zeros(r2-r1,c1)];
        elseif r1>r2
            temp_amend=[temp_amend; zeros(r1-r2,c2)];
        end

        pre_ultimate_level=[pre_ultimate_level temp_amend];
    end
end

% Remove zero rows
pre_ultimate_level( all(~pre_ultimate_level,2), : ) = [];
% Remove zero columns
pre_ultimate_level( :, all(~pre_ultimate_level,1) ) = [];

ultimate_level=sinkIDX;

[r1 c1]=size(ultimate_level);
[r2 c2]=size(pre_ultimate_level);

if c1<c2
    ultimate_level=[ultimate_level zeros(r1,c2-c1)];
elseif c1>c2
    pre_ultimate_level=[pre_ultimate_level zeros(r2,c1-c2)];
end

ultimate_level=[ultimate_level;pre_ultimate_level];

% Adding adjacent nodes of the contaminated nodes/all nodes at the level of contamination node to the level matrix

[r_con,~]=find(ultimate_level==contaminantIDX);

nodes_innerlevel=nonzeros(ultimate_level(1:r_con,:)');

nodes_innerlevel=flip(nodes_innerlevel);

outer_level=cell(length(nodes_innerlevel),1);
outerAllNode=nonzeros(ultimate_level)';

for i=1:length(nodes_innerlevel)

    outer_adjNode_temp=neighbors(gra,nodes_innerlevel(i))';

    outer_adjNode_temp=setdiff(outer_adjNode_temp,outerAllNode);

    outerLevel_temp=[nodes_innerlevel(i) zeros(1,length(outer_adjNode_temp)-1); outer_adjNode_temp];

    outer_level{i,1}=outerLevel_temp;

end
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

if r_con==size(ultimate_level,1)
    psi_level=linspace(0.4,1,size(ultimate_level,1)+1);
else
    psi_level=linspace(0.4,1,size(ultimate_level,1));
end

% Plot pressure head constraints

psibar=zeros(n_H,2);

for i=1:length(psi_level)
    val=psi_level(i);
    for j_nom=1:size(ultimate_level,2)
        try
            psibar(ultimate_level(i,j_nom),:)=[val i];
        end
    end

end

for i=size(outer_level,1):-1:1

    in_IDX=psibar(outer_level{i,1}(1,1),2);

    val=psi_level(in_IDX+1);
    try
        psibar(outer_level{i,1}(2,:),2)=in_IDX+1;
        psibar(outer_level{i,1}(2,:),1)=val;
    end
end

fig = generateGraphpaper(psibar(:,1), Graph, GraphSinks, Graphcont, GraphInlets, numSinks,numinlets,numContaminant,sinksIDX,contaminantIDX,net);