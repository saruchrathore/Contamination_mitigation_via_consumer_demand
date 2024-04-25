% Inputs:
% EPANET class d from MATLAB-EPANET toolkit
% reference node ID (pressure controlled pump) as given in EPANET

function [H,HCbar,HTbar,G,T,indexTree,indexChord,Hbar,HT,HC,refNodeidx,non_ref_nodes] = create_incidence(d,refNodeID)

m = d.getLinkCount;
n = d.getNodeCount;

temp = d.getLinkNodesIndex;
[in] = temp(:,1);
[out] = temp(:,2);

H = zeros(n,m);
for i = 1:m
    H([in(i); out(i)],i) = [1; -1];
end

xCord = d.getNodeCoordinates{1}';
yCord = d.getNodeCoordinates{2}';

weights = d.getLinkLength';

edgeT = table([in, out],weights,d.getLinkNameID','VariableNames',{'EndNodes' 'Weight' 'ID'});
nodeT = table(d.getNodeNameID',[xCord yCord],'VariableNames',{'Name' 'Position'});

G = graph(edgeT,nodeT);
[T, ~] = minspantree(G);

indexTree  = double(sort(d.getLinkIndex(T.Edges.ID))); % Get indexes of pipes in tree and sort after listed order
indexChord = double(setdiff(1:m,indexTree));

refNodeidx = double(d.getNodeIndex(refNodeID));

Hbar=H(setdiff(1:n,refNodeidx),:);

HT=H(:,indexTree);
HC = H(:,indexChord);

non_ref_nodes=double(setdiff(1:n,refNodeidx));

HTbar = H(setdiff(1:n,refNodeidx),indexTree);
HCbar = H(setdiff(1:n,refNodeidx),indexChord);

G = digraph(edgeT,nodeT);

end




