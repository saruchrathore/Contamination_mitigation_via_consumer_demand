function best_row=best_sink(data_percentage,W_contchange,W_time,W_conchange)

if all(data_percentage(:,4)==-Inf)
    data_percentage(:,4)=0;
end


data=data_percentage(:,[2 4 5]);
data=data.*[-W_contchange -W_time W_conchange];

data=sum(data,2);       % Objective function value

[~,best_row]=min(data);     % Find the argument which give the minimum value of the objective function