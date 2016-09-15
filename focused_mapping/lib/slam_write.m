function [] = slam_write(edges,landmark_edges, g2o_filename)
% Convenience Definitions for g2o files
edge_str = 'EDGE2';
edge_format_str = '%s %i %i %10.7f %10.7f %10.7f %10.7f %10.7f %10.7f %10.7f %10.7f %10.7f\n';

% landmark_pos_edge_str = 'EDGE_SE2_XY';
landmark_pos_edge_str = 'LANDMARK';
landmark_pos_edge_format_str = '%s %i %i %10.7f %10.7f %10.7f %10.7f %10.7f \n';

% Open the file
fid = fopen(g2o_filename,'w');

%% Odometry edge information
last_id = edges.id1(1);
dpos = zeros(2,1);
dtheta = 0;
cov = zeros(6,1);
% jj=1;
for ii = 1:length(edges.id1)
    current_id = edges.id2(ii);    
    dpos = edges.dpos(1:2,ii) + [cos(dtheta) sin(dtheta);-sin(dtheta) cos(dtheta)]*dpos;
    dtheta = dtheta+edges.dtheta(1,ii);
    cov(1) = cov(1)+1./edges.infoVec(1,ii);
    cov(4) = cov(4)+1./edges.infoVec(4,ii)';
    cov(6) = cov(6)+1./edges.infoVec(6,ii)';
    if any(current_id==landmark_edges.id1) %|| norm(dpos)>5
        % Write the data to the file
        fprintf(fid,edge_format_str,edge_str,last_id,current_id,...
            dpos(1),dpos(2),dtheta(1),1/cov(1), 0, 0, 1/cov(4), 0, 1/cov(6));
        last_id = current_id;
        dpos = zeros(2,1);
        dtheta = 0;
        cov = zeros(6,1);
%         while jj<=length(landmark_edges.id1) && current_id==landmark_edges.id1(jj)
%             jj=jj+1;        
%         end
%     end
%     if jj>length(landmark_edges.id1)
%         break;
    end
end

%% Point to landmark edge information
for ii = 1:length(landmark_edges.id1)
	% write data
    fprintf(fid,landmark_pos_edge_format_str,landmark_pos_edge_str,...
        landmark_edges.id1(ii),landmark_edges.id2(ii),...
        landmark_edges.dpos(1,ii),landmark_edges.dpos(2,ii),...
        landmark_edges.infoVec(1),landmark_edges.infoVec(2),landmark_edges.infoVec(3));
end

%% Close the file
fclose(fid);