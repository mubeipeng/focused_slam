clear all; close all; 
addpath('./lib');

%% set up parameters
datafile = 'data/simulated.g2o';
glc_file = 'data/glc_node_remove.txt';
isam_path = '../isam/bin/';
landmark_select_method = 'min_mahalanobis'; % or 'max_coverage'
N_focus_landmarks = 30;
N_measure = 80;

%% for simulation, ground truth
landmark_truth = load('data/simulated_landmark_truth')';

%% initialize
[~, node_edge, ~, lm_edge]=parse_isam_file(datafile);
[variableList, J] = initialize_info_matrix(node_edge, lm_edge);

%% generate focused landmarks
[lm_focus_list, t_stage1] = generate_focused_landmark(N_focus_landmarks,lm_edge,node_edge);

%% optimal with all landmarks and measurements
fprintf('\n\n with all landmarks and measurements\n');
project_optimal = optimizeSLAM(node_edge,lm_edge, isam_path,landmark_truth);
fprintf('processing time %f\n',project_optimal.t_optimize);

%% focused landmarks, info selection
fprintf('\n\n use focsed landmarks, and selected measurements\n');
[lm_edge_focus, t_stage2] = generate_measurements('focus_select', J, lm_edge,variableList, lm_focus_list, N_measure);
project_focus = optimizeSLAM(node_edge,lm_edge_focus, isam_path,landmark_truth);
project_focus.t = project_focus.t_optimize+t_stage1+t_stage2;
fprintf('processing time %f\n',project_focus.t);

%% all landmarks, info selection
fprintf('\n\n use all landmarks, and selected measurements\n');
[lm_edge_full, t_stage2] = generate_measurements('full_select', J, lm_edge, variableList, lm_focus_list, N_measure);
project_full = optimizeSLAM(node_edge,lm_edge_full, isam_path, landmark_truth);
project_full.t = project_full.t_optimize+t_stage2;
fprintf('processing time %f\n',project_full.t);

%% focus landmarks, down selection
fprintf('\n\n use focused landmarks, and down-select measurements\n');
[lm_edge_reduced, t_stage2] = generate_measurements('down_select', J, lm_edge,variableList, lm_focus_list, N_measure);
project_down = optimizeSLAM(node_edge,lm_edge_reduced, isam_path, landmark_truth);
project_down.t = project_down.t_optimize+t_stage1+t_stage2;
fprintf('processing time %f\n',project_down.t);

%% glc
fprintf('\n\n use maxcoverage to select landmarks, and use glc to sparsify graph\n');
fprintf('direct apply glc\n');
[variable_remove, t_stage1] = selection_glc(node_edge,lm_edge,N_focus_landmarks);
project_glc_optimize = optimizeGLC(variable_remove, node_edge, lm_edge, isam_path, glc_file, 'true', landmark_truth);
project_glc_optimize.t = project_glc_optimize.t_optimize+t_stage1;
fprintf('processing time %f\n',project_glc_optimize.t);

fprintf('optimize the whole graph first\n');
project_glc_direct = optimizeGLC(variable_remove, node_edge, lm_edge, isam_path, glc_file, 'false', landmark_truth);
project_glc_direct.t = project_glc_direct.t_optimize+t_stage1;
fprintf('processing time %f\n',project_glc_direct.t);
%%
save simulation_results;