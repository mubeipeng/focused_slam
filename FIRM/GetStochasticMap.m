function Map_of_landmarks = GetStochasticMap(varargin) % we overwrite the input map

magnifying_focused_cov = 0.1;

GT_landmarks = varargin{1};
lm_file = varargin{2};

% %%% generate_fake_map
%%%% ==========================================================
% for i = 1:size(GT_landmarks.landmarks,2)
%     focus_weight = is_focused(GT_landmarks.landmarks(:,i));
%     map_landmarks_cov(2*i-1:2*i, 2*i-1:2*i) = eye(2)*magnifying_focused_cov^2*focus_weight^2;
% end
%%%% ==========================================================

% map_landmarks_mean = GT_landmarks.landmarks;
% 
% Map_of_landmarks.obsDim = GT_landmarks.obsDim;
% Map_of_landmarks.landmarks = map_landmarks_mean;
% Map_of_landmarks.covariances = map_landmarks_cov;

GT_landmark = [];

Map_of_landmarks.obsDim = size(GT_landmarks.landmarks,2)*2;
map_landmarks_mean = GT_landmarks.landmarks;
map_landmarks_mean(:,lm_file.id) = lm_file.pos;
Map_of_landmarks.landmarks = map_landmarks_mean;

map_landmarks_cov = eye(2*size(GT_landmarks.landmarks,2))*100;
for i = 1:size(lm_file.id,2)
    id = 2*lm_file.id(i);
%     if ndims(lm_file.cov)==3
%         map_landmarks_cov(id-1:id, id-1:id) = lm_file.cov(:,:,i)*magnifying_focused_cov;
%     else
        map_landmarks_cov(id-1,id-1) = magnifying_focused_cov* exp(-lm_file.entropy(i)/2);
        map_landmarks_cov(id,id) = map_landmarks_cov(id-1,id-1);
%     end
        
%     map_landmarks_cov(id-1:id, id-1:id) = BP_map_cov_update(GT_landmarks.landmarks(:,id/2), lm_file.cov(i));
end
Map_of_landmarks.covariances = map_landmarks_cov;


%% drawing the map
for i = 1:size(map_landmarks_mean, 2)
    cov_i = Map_of_landmarks.covariances(2*i-1:2*i, 2*i-1:2*i);
    if cov_i(1,1) ~=100
        mean_i = map_landmarks_mean(:,i);
        line_width = 3;
        plotUncertainEllip2D(cov_i ,  mean_i ,   'g-', line_width , 0.5);
    else
        plot(map_landmarks_mean(1,i), map_landmarks_mean(2,i), 's', 'color', [0 0.1 0], 'markersize', 12)
    end
end

end


function focusWeight = is_focused(landmark)

focusWeight = 4;

end
