%% Create levels of pressure head gradient from the breadth first search output

num_adj_nodes=length(newmat(2,:));

branch_cell=cell(num_adj_nodes,1);

for i=1:num_adj_nodes
    branch_cell{i,1}(1,1)=newmat(2,i);
end

temp_row=[];

for i=num_adj_nodes+3:length(Nodesall)

    if Nodeevent(i)=='finishnode'

        if isempty(temp_row)

        else
            fin_node=Nodesall(i);
            j=0;
            r_fin=[];
            while isempty(r_fin)
                j=j+1;
                [r_fin,c_fin]=find(branch_cell{j,1}==fin_node);

            end
            [r_bran,c_bran]=size(branch_cell{j,1});
            len_row=length(temp_row);
            branch_cell{j,1}(r_fin+1,c_bran+1:c_bran+len_row)=temp_row;

            temp_row=[];
        end
    else

        temp_row=[temp_row, Nodesall(i)];
    end

end

% for i=1:num_adj_nodes
%     branch_cell{i,1}(1,:)=[];
%     branch_cell{i,1}(:,1)=[];
% end

