function fig = generateSinksGraph(Graph, GraphSinks, GraphInlets,GraphCont,numSinks,numinlets,numContaminant,sinksIDX,contaminantIDX,net)

%colors
pink = [255 153 204]./256;
grey=[50 50 50]./256;
brown = [102 51 0]./256;

fig = figure('units','points','Position',[0 0 1200 550]);
p = plot(Graph,'Interpreter','latex','EdgeColor',grey,'NodeFontSize',7,'MarkerSize',7,'LineWidth',2);
% Remove old labels
p.NodeLabel = {};

% Add sink nodes labels
coor=net.getNodeCoordinates;
x=coor{1}(sinksIDX);y=coor{2}(sinksIDX);
fontweight='bold';
fontsize=18;
for i=1:length(sinksIDX)
    text(x(i)+20,y(i)+20,net.getNodeNameID{sinksIDX(i)},'Color','black','FontWeight',fontweight,'Fontsize',fontsize);
end

% Add contamination nodes labels
x=coor{1}(contaminantIDX);y=coor{2}(contaminantIDX);
for i=1:length(contaminantIDX)
    text(x(i)-35,y(i)+35,net.getNodeNameID{contaminantIDX(i)},'Color','black','FontWeight',fontweight,'Fontsize',fontsize);
end
hold on
caxis([0 1]);
p.XData = Graph.Nodes.Position(:,1);
p.YData = Graph.Nodes.Position(:,2);
p.ArrowSize = 0;

p2 = plot(GraphInlets,'Interpreter','latex');
p2.XData = GraphInlets.Nodes.Position(:,1);
p2.YData = GraphInlets.Nodes.Position(:,2);
highlight(p2,numinlets,'Marker','s','MarkerSize',18);
p2.NodeLabel = '';
p2.NodeColor = pink;
p2.ArrowSize = 0;

p3 = plot(GraphSinks,'Interpreter','latex');
p3.XData = GraphSinks.Nodes.Position(:,1);
p3.YData = GraphSinks.Nodes.Position(:,2)-0e3;
highlight(p3,numSinks,'Marker','p','MarkerSize',18);
p3.NodeLabel = '';
p3.NodeColor = 'red';
p3.ArrowSize = 0;

p4 = plot(GraphCont,'Interpreter','latex');
p4.XData = GraphCont.Nodes.Position(:,1);
p4.YData = GraphCont.Nodes.Position(:,2)+0e3;
highlight(p4,numContaminant,'Marker','d','MarkerSize',15);
p4.NodeLabel = '';
p4.NodeColor = brown;
p4.ArrowSize = 0;

daspect([1 1 1])
set(gca,'Visible','off')
hold off
%
%
