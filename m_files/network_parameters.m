disp('Creating Model of the network...')
syms e_sym D_sym L_sym f_sym kf_sym real      % Symbolic (epsilon, diameter, length, friction coeff, foam loss coeff.)

% Defining the friciton coeff. eq symbolically
friction_coeff_func=1.325*(log(e_sym/(3.7*D_sym)+5.74/R^0.9))^(-2);
friction_coeff_func=matlabFunction(friction_coeff_func);

% Calculating friction coeff. for each edge
friction_coeff=zeros(m_H,1);
for i=1:m_H
    friction_coeff(i,1)=friction_coeff_func(diameter_pipe(i),epsilon(i));
end

% Defining the friction loss eq symbolically
friction_loss_func=f_sym*8*L_sym*rho_fluid/(pi^2*D_sym^5*1e05*(36e02)^2);
friction_loss_func=matlabFunction(friction_loss_func);

% Calculating friction loss for each edge
friction_loss=zeros(m_H,1);
for i=1:m_H
    friction_loss(i,1)=friction_loss_func(diameter_pipe(i),length_pipe(i),friction_coeff(i));
end


% Calculating overall loss for each edge
lambda=2*friction_loss;          % Considering foam loss is equal to the friction loss

n_chords=length(set_chord);
B_unsort=[eye(n_chords) -H_C_bar'*inv(H_T_bar')];   % Generate loop matrix with edge index as [chords tree].

idx=[set_chord edge_tree];                      % set index for unsorted B matrix

for i =1:size(B_unsort,1)
    B(i,idx)=B_unsort(i,:);
end

height_node_bar=height_node*rho_fluid*g/1e5;    % [bar] Pressure due to geodesic level at nodes
z=height_node_bar;
z_bar=height_node_bar(non_ref_nodes);           % [bar] Pressure due to geodesic level at non-reference nodes
z_n=height_node_bar(ref_node);                  % [bar] Pressure due to geodesic level at reference nodes