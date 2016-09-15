function y = compute_min_Mahalobinas(node_edge, lm_edge, lm)
% compute min Mahalobinas dist
Q = 1/node_edge.infoVec(1,1);
R_info = lm_edge.infoVec(1,1);
R_prior=0.1;

N_odom = length(node_edge.id2);
n_observed_lm = R_info*ones(1,N_odom); % No. of landmarks observed at each odom node

for i=1:length(lm.id)
    idx = lm_edge.id1( lm_edge.id2==lm.id(i)+node_edge.id2(end) );
    n_observed_lm(idx) =  n_observed_lm(idx)+1/sqrt(det( lm.cov(:,:,i) ));
end

node_cov = 0.5*Q+0.5*sqrt( Q.^2+4.*Q./(R_prior+n_observed_lm) );
idx = node_edge.observe_lm;
y = min( node_edge.closeP(idx)./node_cov(idx).*node_edge.closeP(idx) );
end