function project = parse_gcl()
fid=fopen('g2o_files/simluated_glc.txt');

nodes=[];
lms=[];
edges=[];
line=fgets(fid);
while (line~=-1)
    space=find(line==' '); bra1=find(line=='('); bra2=find(line==')');
    if(line(1:3)=='Pos')        
        node = str2num(line([space(1):space(2) bra1+1:bra2-1]));
        nodes = [nodes; node];
    end
    if(line(1:3)=='Poi')
        lm = str2num(line([space(1):space(2) bra1+1:bra2-1]));
        lms = [lms; lm];
    end
    if(line(1:3)=='GLC')
        edge = str2num(line([space(1):space(3)]));
        edges = [edges; edge];
    end
    line=fgets(fid);
end
fclose(fid);

project.node.id = nodes(:,1)';
project.node.pos = nodes(:,2:end)';

project.lm.id=lms(:,1)';
project.lm.pos=lms(:,2:end)';

project.lm_edge.id1 = edges(:,1)';
project.lm_edge.id2 = edges(:,2)';