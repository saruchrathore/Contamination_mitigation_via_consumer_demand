function D = nodeTopologicalDistance(inpname,dispname)
%%% Calculates D matrix, the distance of each node from other nodes

%% Find minimum topological distance between all nodes:
D_filename = [pwd,'\saved_mat\D_Mat_',dispname,'.mat'];
if isfile(D_filename)
    % File exists:
    load(D_filename)
else
    % File does not exist:
    %%% Load Network
    d=epanet(inpname);
    %%%
    disp('Calculating min topological distances...')
    %%% D: nxn matrix with node distance
    %%% dmax: max distance in the network
    A = d.getConnectivityMatrix; % Adjacency matrix
    connNodes = d.NodesConnectingLinksIndex;
    pipeLengths = d.getLinkLength;
    for i = 1:length(connNodes)
        A(connNodes(i,1),connNodes(i,2)) = pipeLengths(i);
        A(connNodes(i,2),connNodes(i,1)) = pipeLengths(i);
    end    
    A = graph(A);
    D = distances(A);
    save(['saved_mat\D_Mat_',dispname],'D')
    disp('Topological distance matrix created!')
    %%% Unload
    d.unload
end

end