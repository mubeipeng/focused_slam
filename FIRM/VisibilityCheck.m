function Full_data = VisibilityCheck(Full_data)

n_waypoints = size(Full_data.logged_data,1);

for wayPoint_id = 1:n_waypoints
    for k = 1 : length(Full_data.logged_data(wayPoint_id,:))
        if isempty(Full_data.logged_data(wayPoint_id,k).x)
            break
        end
        
        x = Full_data.logged_data(wayPoint_id,k).x;
        
        visibility{wayPoint_id,k} = CheckLandmarkVisibility(x,Full_data.landmark_map_GT, Full_data.obstacle_map);
        
        disp([wayPoint_id, k])
        
    end
end

Full_data.visibility = visibility;

end


function YesNo = CheckLandmarkVisibility(x,landmark_map_GT, obstacle_map)

for id_landmark = 1:length(landmark_map_GT)
    Lx = landmark_map_GT(1,id_landmark);
    Ly = landmark_map_GT(2,id_landmark);
    
    angle = atan2(Ly-x(2), Lx-x(1)) - x(3);
    
    front = 0;
    if angle >=-pi/2 && angle <=pi/2
        %front = FrontOrBackOfRobot(Lx, Ly, line);
        front = 1;
    end
    
    YesNo(id_landmark) = 1;
    
    if ~front
        YesNo(id_landmark) = 0;
    else
        N_obst = size(obstacle_map,2);
        for ib=1:N_obst
            X_obs=[obstacle_map{ib}(:,1);obstacle_map{ib}(1,1)];
            Y_obs=[obstacle_map{ib}(:,2);obstacle_map{ib}(1,2)];
            X_ray=[x(1), Lx];
            Y_ray= [x(2), Ly];
            [x_inters,~] = polyxpoly(X_obs,Y_obs,X_ray,Y_ray);
            if ~isempty(x_inters)
                YesNo(id_landmark) = 0;
                break
            end
        end
        
    end
    
end

end


