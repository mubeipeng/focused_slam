function [lm_edge, t] = generate_measurements(name,J, lm_edge,  variableList, focus_lm_list, N_select)
tic
switch name
    case 'focus_select'
        selectIdx = selection_focus(J, variableList, focus_lm_list, N_select, lm_edge);        
    case 'full_select'
        selectIdx = selection_full(J, variableList, N_select, lm_edge);       
    case 'down_select'
        selectIdx = selection_down(focus_lm_list, N_select, lm_edge);
    case 'down_all'
        selectIdx = false(length(lm_edge.id1),1);
        for i=1:length(focus_lm_list)
            selectIdx(lm_edge.id2==focus_lm_list(i))=true;
        end
    otherwise
        fprintf('unrecoginizable selection method');
end
t = toc;
% generate reduced set of measurements
lm_edge.id1 = lm_edge.id1(selectIdx);
lm_edge.id2 = lm_edge.id2(selectIdx);
lm_edge.dpos = lm_edge.dpos(:,selectIdx);
lm_edge.infoVec = lm_edge.infoVec(:,selectIdx);
end

%%
function selectIdx = selection_down(lm_focus_list, N_select, landmark_edge)
selectIdx = false(length(landmark_edge.id1),1);
candidates=[];
for i=1:length(lm_focus_list)
    candidates=[candidates find(landmark_edge.id2==lm_focus_list(i))];
end
N = length(candidates);
delta = floor((N-1)/N_select);
start = ceil(rand*(N - N_select*delta));
selectIdx(candidates(start:delta:N))=true;
end

%%
function [selectIdx] = selection_focus(J, variableList, lm_focus_list, N, landmark_edge)
% compute focus covariance matrix and marginal unfocused covariance matrix
focusIdx = false(size(variableList));
for t=1:length(lm_focus_list) 
    focusIdx(variableList==lm_focus_list(t))=true;
end
cov_full = inv(J);
cov_cc = zeros(size(J));
cov_cc(~focusIdx,~focusIdx) = cov_full(~focusIdx,~focusIdx)...
    - cov_full(~focusIdx,focusIdx)/cov_full(focusIdx,focusIdx)*cov_full(focusIdx,~focusIdx);

selectIdx = false(length(landmark_edge.id1),1);
for i=1:N
    fprintf('compute measure %i\n',i);
    % compute values
    edge_value = zeros(size(variableList));
    parfor t=1:length(landmark_edge.id1)
        if ~selectIdx(t)
            vIdx1 = find(variableList==landmark_edge.id1(t));
            vIdx2 = find(variableList==landmark_edge.id2(t));
            vIdx = [vIdx1 vIdx2];
            
            noise = landmark_edge.infoVec(1,t);
            edge_value(t) = log(1+noise*[1 -1]*cov_full(vIdx,vIdx)*[1;-1])...
                           -log(1+noise*[1 -1]*cov_cc(vIdx,vIdx)*[1;-1]);
        end
    end
    [~,idx] = max(edge_value);
    selectIdx(idx)=true;
     vIdx1 = find(variableList==landmark_edge.id1(idx));
     vIdx2 = find(variableList==landmark_edge.id2(idx));
     vIdx = [vIdx1 vIdx2];
    noise = landmark_edge.infoVec(1,idx);
    
    % update covariance matrix
    cov_full = cov_full - noise/(1+noise*[1 -1]*cov_full(vIdx,vIdx)*[1;-1])...
        *cov_full(:,vIdx)*[1 -1; -1 1]*cov_full(vIdx,:);
    %if(~focusIdx(vIdx1) && ~focusIdx(vIdx2))
        cov_cc(~focusIdx,~focusIdx) = cov_full(~focusIdx,~focusIdx)...
            - cov_full(~focusIdx,focusIdx)/cov_full(focusIdx,focusIdx)*cov_full(focusIdx,~focusIdx);
    %end
end
end

%% 
function [selectIdx] = selection_full(J, variableList, N_select, landmark_edge)
cov_full = inv(J);
selectIdx = false(length(landmark_edge.id1),1);
for i=1:N_select
    fprintf('compute measure %i\n',i);
    % compute values
    edge_value = zeros(size(variableList));
    parfor t=1:length(landmark_edge.id1)
        if ~selectIdx(t)
            vIdx1 = find(variableList==landmark_edge.id1(t));
            vIdx2 = find(variableList==landmark_edge.id2(t));
            vIdx = [vIdx1 vIdx2];
            noise = landmark_edge.infoVec(1,t);
            edge_value(t) = log(1+noise*[1 -1]*cov_full(vIdx,vIdx)*[1;-1]);
        end
    end
    [~,idx] = max(edge_value);
    selectIdx(idx)=true;
     vIdx1 = find(variableList==landmark_edge.id1(idx));
     vIdx2 = find(variableList==landmark_edge.id2(idx));
     vIdx = [vIdx1 vIdx2];
    noise = landmark_edge.infoVec(1,idx);
    
    % update covariance matrix
    cov_full = cov_full - noise/(1+noise*[1 -1]*cov_full(vIdx,vIdx)*[1;-1])...
        *cov_full(:,vIdx)*[1 -1; -1 1]*cov_full(vIdx,:);
end
end