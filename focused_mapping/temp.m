hold on;
plot(project_focus.lm.pos(1,:),project_focus.lm.pos(2,:),'sr');
plot(project_focus.nodes.pos(1,:),project_focus.nodes.pos(2,:),'k','LineWidth',3.0);

for i=1:length(project_focus.lm_edge.id1)
    idx1= project_focus.nodes.id==project_focus.lm_edge.id1(i);
    pos1= project_focus.nodes.pos(:,idx1);
    
    idx2 = project_focus.lm.id == project_focus.lm_edge.id2(i);
    pos2 = project_focus.lm.pos(:,idx2);
    
    text(pos1(1),pos1(2),num2str(project_focus.lm_edge.id1(i)));
    plot([pos1(1) pos2(1)],[pos1(2) pos2(2)],'b--');
end
    
%%
hold on;
plot(landmark_truth(2,:),landmark_truth(3,:),'kx');
if any(lm_focus_list>1500)
    ll=lm_focus_list-1992;
else
    ll=lm_focuse_list;
end
plot(landmark_truth(2,ll),landmark_truth(3,ll),'rd');
for i=1:length(lm_focus_list)
    text(landmark_truth(2,ll(i)),landmark_truth(3,ll(i)),num2str(i));
end
