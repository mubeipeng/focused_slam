function project = optimizeGLC(variable_remove, node_edge, lm_edge, isam_path, glc_file,lm_truth)
%% write variables to remove
fid = fopen(glc_file,'w');
for i=1:length(variable_remove)
    fprintf(fid,'%d\n',variable_remove(i));    
end
fclose(fid);

%% write isam file
g2o_file = 'data/output.g2o';
slam_write(node_edge,lm_edge,g2o_file);

%% optimize
tic;
system([isam_path, 'sparse_graph_glc ', g2o_file, ' ', glc_file, ' ', g2o_file]);
project.t_optimize=toc;

%% read
[project.nodes,project.node_edge,project.lm,project.lm_edge]=parse_isam_file(g2o_file);
ids = unique(lm_edge.id2,'stable') - node_edge.id2(end);
project.lm.id = ids(project.lm.id - node_edge.id2(end));


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
    
    project.lm_transformed = pos_calculated;    
end

%% compute min Mahalobinas dist
Q = 1/node_edge.infoVec(1,1);
R_info = lm_edge.infoVec(1,1);
R_prior=0.1;

odom = unique(node_edge.id1);
n_observed_lm =  hist(project.lm_edge.id1,odom);
node_cov = 0.5*Q+0.5*sqrt( Q.^2+4.*Q./(R_prior+R_info*n_observed_lm) );
idx = node_edge.observe_lm;
project.min_mahalobinas = min( node_edge.closeP(idx)./node_cov(1,idx).*node_edge.closeP(idx) );
end