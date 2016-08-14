function [lm_focused,t] = generate_focused_landmark(N,lm_edge,node_edge,select_method)
tic;
% nodes that can observe lm
idx_obs_lm = unique(lm_edge.id1);
if(idx_obs_lm(1)==0) 
    idx_obs_lm(1)=[];
end

%%
lm_list = unique(lm_edge.id2);
lm_focused = [];

N_odom = length(node_edge.id2);
n_observed_lm = zeros(N_odom,1); % No. of landmarks observed at each odom node

%%
%% process and measurement noise for riccate equation
Q = 1/node_edge.infoVec(1,1);
R_info = lm_edge.infoVec(1,1);
R_prior=0.1;

node_cov = 0.5*Q+0.5*sqrt( Q.^2+4.*Q./(R_prior+R_info*n_observed_lm) );
odom_count(unique(lm_edge.id1)) = hist(lm_edge.id1,unique(lm_edge.id1));
for n = 1:N
    %% Mahalanobis distance
    dist_mahalanobis = node_edge.closeP./node_cov(1,:).*node_edge.closeP;    
    min_dist=min(dist_mahalanobis(odom_count>0));
    %%
    minDist = zeros(size(lm_list));
    for jj=1:length(lm_list)
        if ~any(lm_list(jj)==lm_focused)
            idx = lm_edge.id1( lm_edge.id2==lm_list(jj)); %odom idx observe landmark jj
            switch select_method
            case 'min_mahalanobis'
                minDist(jj) = sum(dist_mahalanobis(idx)>1.2*min_dist);
            case 'max_coverage'
%                 minDist(jj) = mean(dist_mahalanobis(idx)+1);        
                minDist(jj) = sum(n_observed_lm(idx)==0);
            end
        end
    end        
    [~, lm_idx] = max(minDist);
    lm_id = lm_list(lm_idx);
    
    lm_focused = [lm_focused lm_id];
    
    %% update number of observed landmarks
    lm_meas_idx = lm_edge.id2==lm_id;
%     lm_meas_idx(1)=false; % initial odom forced to have no observation of landmarks
    odom_id = lm_edge.id1(lm_meas_idx);
    odom_count(odom_id) = odom_count(odom_id)-1;
    n_observed_lm(odom_id) = n_observed_lm(odom_id)+1;
    node_cov(odom_id) = 0.5*Q+0.5*sqrt( Q.^2+4.*Q./(R_prior+R_info*n_observed_lm(odom_id)) );
end
t=toc;
% %% select extra landmarks to cover the space
% % process J
% n_var = length(J);
% for n=1:N
%     H = jaccobian(lm_meas,R_info,lm_focused(n),n_var,variablelist);
%     J = J+H*H';
% end
% 
% Lambda = inv(J);
% lm_id = unique(lm_meas.id2);
% for i=1:10
%     gap = zeros(length(lm_id),1);
%     parfor jj=1:length(lm_id)
%         if ~any(lm_focused==lm_id(jj))
%             H = jaccobian(lm_meas,R_info,lm_id(jj),n_var,variablelist);
%             gap(jj)= log(1+H'*Lambda*H);
%         end
%     end
%     [~, idx]=max(gap);
%     lm_focused = [lm_focused lm_id(idx)];
%     H = jaccobian(lm_meas, R_info, lm_id(idx), n_var, variablelist);
%     L = Lambda*H;
%     Lambda = Lambda - L/(1+H'*Lambda*H)* L';
% end
end

function H = jaccobian(lm_meas, R_info, lm_id, n_var,variableList)
H=zeros(n_var,1);
lm_idx = lm_id==variableList;
n_meas = 0;
for i=1:n_var
    if lm_meas.id2(i)==lm_id;
        odom_idx = variableList== lm_meas.id1(i);
        H(odom_idx) = -R_info;
        n_meas = n_meas+1;
    end
end
H(lm_idx) = R_info*n_meas;
end