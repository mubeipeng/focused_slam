function [variable_remove,t] = selection_glc(node_edge,lm_edge,N_select)
tic
%% select landmarks
variableList = unique([node_edge.id2 lm_edge.id2]);
N_odom = length(node_edge.id2);
N_var = length(variableList);
variable_retain = false(1,N_var);

selected = zeros(N_odom,1);
for i=1:N_select
    gap = -5000*ones(1,N_var);
    for jj=N_odom+1:N_var
        if ~variable_retain(jj)
            idx = lm_edge.id1(lm_edge.id2 ==variableList(jj));
            selected_new = selected; selected_new(idx)=selected_new(idx)+1;
            gap(jj) = sum(selected_new>=1)-sum(selected>=1);
%             if gap(jj)==0
%                 gap(jj) = sum(selected_new>=2)-sum(selected>=2);
%             end
            if gap(jj)==0
                gap(jj) = -5000+length(lm_edge.id1(lm_edge.id2 ==variableList(jj) ));
            end       
        end
    end
    [g, minidx]=max(gap);    
    idx = lm_edge.id1(lm_edge.id2 ==variableList(minidx))+1;
    selected(idx)=true;
    variable_retain(minidx)=true;   
end

% hold on; axis equal;
% plot(node.pos(1,:),node.pos(2,:));
% for i=1:length(variableList);
%     if(variable_retain(i))
%         idx = lm.id==variableList(i);
%         plot(lm.pos(1,idx),lm.pos(2,idx),'dr');
%         text(lm.pos(1,idx),lm.pos(2,idx),[num2str(i)]);     
%     end
% end


%% select poses
dist_accru = 0;
% variable_retain(1)=true;
for ii=1:N_odom
    dist_accru = dist_accru + norm(node_edge.dpos(1:2,ii));
    if dist_accru>=1.2
        variable_retain(ii)=true;
        dist_accru = 0;
    end
end
% plot(node.pos(1,variable_retain(1:1993)),node.pos(2,variable_retain(1:1993)),'x-')
variable_remove = variableList(~variable_retain);

t=toc;
end