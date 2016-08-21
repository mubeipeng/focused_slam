function wayPoints = getWayPoints()

load('output/Single_log_sim_BP')

wayPoints{1} = Full_data_visibility.logged_data(2,1).x;
for i = 2:size(Full_data_visibility.logged_data,1)
    x_new = [Full_data_visibility.logged_data(i,:).x];
    wayPoints{i} = x_new(:,end);
end
