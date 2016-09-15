function [nnode, nnode_edge, llm, llm_edge]=parse_isam_file(filename)

node_edge=[];
lm_edge=[];
node=[];
lm=[];
lm_cov=[];
pose_cov=[];

fid = fopen(filename);
tline = fgetl(fid);
while ischar(tline)
    tline = strrep(tline,'(',''); tline=strrep(tline,')',' ');tline=strrep(tline,',',' ');
    tline=strrep(tline,'{',' ');tline=strrep(tline,'}',' ');
    space = strfind(tline,' '); space=space(1);
    str = tline(1:space-1);
    if strcmp(str,'COV')
        c = [str2num(tline(space+1:end))];
        if length(c)==5
            lm_cov(end+1,:)=c;
        else
            pose_cov(end+1,:)=c;
        end
        
    end
    if strcmp(str,'Pose2d_Pose2d_Factor') || strcmp(str,'EDGE2')
        node_edge(end+1,:) = [str2num(tline(space+1:end))];
    end
    if strcmp(str,'Pose2d_Point2d_Factor') || strcmp(str,'LANDMARK')
        lm_edge(end+1,:)=[str2num(tline(space+1:end))];        
    end
    if strcmp(str,'Pose2d_Node')
        node(end+1,:)=str2num(tline(space+1:end));
    end
    if strcmp(str,'Point2d_Node')
        lm(end+1,:)=[str2num(tline(space+1:end))];
    end 
    if strcmp(str,'GLC_Factor')
        data = [str2num(tline(space+1:end))];
        if data(1)>data(2)
            data(1:2) = data([2 1]);
        end
        lm_edge(end+1,1:2)=data(1:2);
    end 
    tline = fgetl(fid);
end
fclose(fid);

if size(lm)>1
    llm.id=lm(:,1)';
    llm.pos=lm(:,2:3)';
else
    llm=[];
end

if ~isempty(lm_edge)
    llm_edge.id1=lm_edge(:,1)';
    llm_edge.id2=lm_edge(:,2)';
    llm_edge.dpos=lm_edge(:,3:4)';
    llm_edge.infoVec=lm_edge(:,5:7)';    
else
    llm_edge=[];
end

if size(node)>0
    nnode.id=node(:,1)';
    nnode.pos=node(:,2:3)';
    nnode.theta=node(:,4)';
else
    nnode=[];
end

if ~isempty(node_edge)
    nnode_edge.id1=node_edge(:,1)';
    nnode_edge.id2=node_edge(:,2)';
    nnode_edge.dpos=node_edge(:,3:4)';
    nnode_edge.dtheta = node_edge(:,5)';
    nnode_edge.infoVec = node_edge(:,6:11)';
else
    nnode_edge=[];
end

if size(node_edge,2)>11
     nnode_edge.closeP = node_edge(:,12)';
     observable_nodes = unique(llm_edge.id1);
     nnode_edge.observe_lm = false(1,length(nnode_edge.id1));
     nnode_edge.observe_lm(observable_nodes)=true;
end

if ~isempty(lm_cov)
    for i=1:size(lm_cov,1)
        idx = find(llm.id==lm_cov(i,1));
%         llm.cov(:,:,idx)=reshape(lm_cov(i,2:end),2,2);
        cov_i = reshape(lm_cov(i,2:end),2,2);
        llm.entropy(idx)= - log(det(cov_i));
        
    end
end
if ~isempty(pose_cov)
    for i=1:size(pose_cov,1)
        idx = find(nnode.id==pose_cov(i,1));
        cov_i = reshape(pose_cov(i,2:end),3,3);
        nnode.entropy(idx)= - log(det(cov_i));
    end
end