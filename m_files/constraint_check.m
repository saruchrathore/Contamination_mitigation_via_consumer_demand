function all_good=constraint_check(heads,ultimate_level,outer_level)

con_check=true;

% Inner level

for i=1:size(ultimate_level,1)-1
    for j=1:size(ultimate_level,2)
        for k=1:size(ultimate_level,2)
            try
                con_check=heads(ultimate_level(i,j))<=heads(ultimate_level(i+1,k));
            end
            if ~con_check
                break
            end
        end
        if ~con_check
            break
        end
    end
    if ~con_check
        break
    end
end

% Outer level

for i=1:length(outer_level)
    if ~con_check
        break
    end
    try
        con_check=heads(outer_level{i,1}(1,1))<=heads(outer_level{i,1}(2,:));
    end
end


% Check

if ~con_check
    all_good=0;
else
    all_good=1;
end
