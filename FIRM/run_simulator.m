function l = run_simulator(lm_file)
global par;
load('output/current_parameters');

%% robot for simulator side (ground truth models)
robot_labels_GT.state = par.state_parameters.label(1:end-2);
robot_labels_GT.mm = par.motion_model_parameters.label(1:end-2);
robot_labels_GT.om = par.observation_model_parameters.label(1:end-2);
robot_labels_GT.belief = [par.state_parameters.label(1:end-7),'belief'];

%% instantiate the simulator
simulator = 'Embedded_Simulator';
sim = feval(par.simulator_parameters.label(1:end-2));
sim = sim.initialize(robot_labels_GT);
global obstacle_map; %#ok<NUSED> % This is only for Beipeng's paper
obstacle_map = sim.obstacle.obst;

emptyRobot_GroundTruthModels = robot_class(nan, robot_labels_GT.state, robot_labels_GT.mm, robot_labels_GT.om, robot_labels_GT.belief, sim.landmarkMap);
sim = sim.addRobot(emptyRobot_GroundTruthModels);

%% robot for algorithm side (computational models - NOT ground truth)
robot_labels.state = par.state_parameters.label(1:end-2);
robot_labels.mm = par.motion_model_parameters.label(1:end-2);
robot_labels.om = 'Map_based_Range_bearing';
robot_labels.belief = [par.state_parameters.label(1:end-7),'belief'];

%%
Stochastic_Map_of_landmarks = GetStochasticMap(sim.landmarkMap,lm_file);
emptyRobot = robot_class(nan, robot_labels.state, robot_labels.mm, robot_labels.om, robot_labels.belief, Stochastic_Map_of_landmarks);

global om_computational;
om_computational = emptyRobot.om;


%% This is where you should write your specific planning problem
for i=1:17
    i
% prob_inst = Beipeng_Planning_Problem(sim,emptyRobot);
    prob_inst = Navigation_Problem(sim,emptyRobot);
%prob_inst = Tube_visualization_Problem(sim,emptyRobot);
    logged_data= prob_inst.solve();    
    l(i) = length(logged_data.cov);
end
sim = sim.simDelete();
end