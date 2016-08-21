clear classes;clear variables;close all;clc;

% Add FIRM toolbox and external toolboxes as needed to the Matlab path
addpath(genpath(pwd))
add_external_toolboxes()

% Parameters
user_data = user_data_class; % The object user_data will never be used. This line only cause the "Constant" properties of the "user_data_class" class to be initialized.
if user_data_class.par.Cancel_Run == 1
    disp('User canceled the program run.')
    return
end

% The following lines should be read from USER_INPUT asap.
robot_labels.state = user_data.par.state_parameters.label(1:end-2);
robot_labels.mm = user_data.par.motion_model_parameters.label(1:end-2);
robot_labels.om = user_data.par.observation_model_parameters.label(1:end-2);
robot_labels.belief = [user_data.par.state_parameters.label(1:end-7),'belief'];

% instantiate the simulator
simulator = 'Embedded_Simulator';
sim = feval(user_data.par.simulator_parameters.label(1:end-2));
sim = sim.initialize(robot_labels);

emptyRobot = robot_class(nan, robot_labels.state, robot_labels.mm, robot_labels.om, robot_labels.belief, sim);
sim = sim.addRobot(emptyRobot);

load('output/Single_log_sim_BP')

n_waypoints = size(Full_data_visibility.logged_data,1);

for wayPoint_id = 1:n_waypoints
    for k = 1 : length(Full_data_visibility.logged_data(wayPoint_id,:))
        if isempty(Full_data_visibility.logged_data(wayPoint_id,k).x)
            break
        end
        
        x = Full_data_visibility.logged_data(wayPoint_id,k).x;
        xState = feval('planar_robot_XYTheta_state',x);
        belief =  feval('planar_robot_XYTheta_belief',xState,eye(3));
        sim = sim.setRobot(xState);
        sim = sim.setBelief(belief);
        sim = sim.refresh();
        
        visible_landmark_x = Full_data_visibility.landmark_map_GT(1,Full_data_visibility.visibility{wayPoint_id,k} == 1);
        visible_landmark_y = Full_data_visibility.landmark_map_GT(2,Full_data_visibility.visibility{wayPoint_id,k} == 1);
        plot(visible_landmark_x, visible_landmark_y, '*r')
        pause
        plot(visible_landmark_x, visible_landmark_y, '*b')
        disp([wayPoint_id, k])
        
    end
end

