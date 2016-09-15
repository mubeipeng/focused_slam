function [variableList, J] = initialize_info_matrix(node_edge, lm_edge)
variableList = unique([node_edge.id1 node_edge.id2 lm_edge.id2]);
N_var = length(variableList);

J = zeros(N_var,N_var);
J(1,1)=1e8;
for t=1:length(node_edge.id1);
    % compute covirance, proportional to distance of two poses.
    vIdx1 = find(variableList==node_edge.id1(t));
    vIdx2 = find(variableList==node_edge.id2(t));
    
    J(vIdx1,vIdx1)=J(vIdx1,vIdx1)+node_edge.infoVec(1,t);
    J(vIdx1,vIdx2)=J(vIdx1,vIdx2)-node_edge.infoVec(1,t);
    J(vIdx2,vIdx1)=J(vIdx1,vIdx2);
    J(vIdx2,vIdx2)=J(vIdx2,vIdx2)+node_edge.infoVec(1,t);    
end

for t=1:length(J)
    if J(t,t)<1e-4
        J(t,t)=1e-4;
    end
end