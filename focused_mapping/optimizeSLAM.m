function project = optimizeSLAM(node_edge,lm_edge,isam_path,lm_truth)
%% optimize
g2o_file = 'data/output.g2o';
slam_write(node_edge,lm_edge,g2o_file);
tic;
system([isam_path, 'isam -B -W ', g2o_file,' ',g2o_file]);
project.t_optimize=toc;
[project.nodes,project.node_edge,project.lm,project.lm_edge]=parse_isam_file(g2o_file);

project.lm.id = unique(lm_edge.id2,'stable');
project.lm.id = project.lm.id-node_edge.id2(end);

%% output statistics
fprintf('number of poses %d\n', length(project.nodes.id));
fprintf('number of landmarks %d\n', length(project.lm.id));
fprintf('number of factors %d\n', length(project.node_edge.id1)+length(project.lm_edge.id1));

%% compute error
if ~isempty(lm_truth)
    pos_calculated = project.lm.pos;
    pos_calculated(3,:)=0;
    
    pos_opt = zeros(3,length(project.lm.id));
    pos_opt(1:2,:) = lm_truth(2:3,project.lm.id);
    
    T = estimateRigidTransform(pos_opt,pos_calculated);
    pos_calculated(4,:)=1;
    pos_calculated = T(1:3,:)*pos_calculated;

    project.lm.err = sqrt(sum( (pos_opt - pos_calculated).^2));
    project.err = mean(project.lm.err);
    fprintf('mean error on landmarks: %f\n',project.err);    
    project.lm_transformed = pos_calculated;    
end

end