function par_new = Input_XML_reader(old_par, par_new_from_GUI)

%  Parameters (they have to go into an XML)
%=======================================================================================
par_new = par_new_from_GUI;   % first we copy the newly provided parameters from GUI

%=========== Random seed
seed = 502; 
rand('state',seed); %#ok<RAND>
randn('state',seed); %#ok<RAND>
par_new.seed = seed;

%=========== Stabilizer Parameters
par_new.stabilizer_parameters.max_stopping_time = 50;
par_new.stabilizer_parameters.draw_cov_centered_on_nominal = 0;

%=========== MonteCarlo Simulation
par_new.par_n = 20; % number of particles
par_new.cost_gain = 10;

%=========== (LQR design) Node and Edge controller
par_new.LQR_cost_coefs=[0.03*0.1 , 0.03*0.1 , 0.1];  % first entry is the "final state cost coeff". The second is the "state cost coeff", and the third is the "control cost coeff".

par_new.state_cost_ratio_for_stationary_case = 5; % note that "state_cost" is for the trajectory tracking. Usually in point stabilization, we need more force on state and less on control. So, we multiply the "state_cost" to an appropriate ratio, i.e., "state_cost_ratio_for_stationary_case". Note that this ratio has to be greater than 1.
par_new.control_cost_ratio_for_stationary_case = 1/5; % note that "control_cost" is for the trajectory tracking. Usually in point stabilization, we need more force on state and less on control. So, we multiply the "control_cost" to an appropriate ratio, i.e., "control_cost_ratio_for_stationary_case". Note that this ratio has to be LESS than 1.


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%==============================================================================================================
%==============================================================================================================
%==============================================================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmpi(par_new.motion_model_parameters.label,'Multi RandomWalk robots')
    n = par_new.state_parameters.num_robots;
    par_new.valid_linearization_domain = repmat([3;3]*4 , n , 1);
elseif strcmpi(par_new.motion_model_parameters.label,'Multi Omni-directional robots')
    n = par_new.state_parameters.num_robots;
    par_new.valid_linearization_domain = repmat([3;3;75*pi/180]*3 , n , 1);
elseif strcmpi(par_new.motion_model_parameters.label,'Revolute joint 8arm manipulator')
    par_new.valid_linearization_domain = ones(par_new.state_parameters.stateDim , 1)*75*pi/180;
elseif strcmpi(par_new.motion_model_parameters.label,'Dynamical planar 8arm manipulator')
    par_new.valid_linearization_domain = [ones(par_new.state_parameters.stateDim/2 , 1)*75*pi/180; ones(par_new.state_parameters.stateDim/2 , 1)*1000*pi/180];
elseif strcmpi(par_new.motion_model_parameters.label, 'FixedWing Aircraft')
    par_new.valid_linearization_domain = [3;3;3;1;1;1;1]*3;
elseif strcmpi(par_new.motion_model_parameters.label,'Quadrotor')
    par_new.valid_linearization_domain = [3;3;3;75*pi/180;75*pi/180;75*pi/180;inf;inf;inf;inf;inf;inf];
else
    par_new.valid_linearization_domain = [3;3;75*pi/180]*3;
end


%=========== HBRM cost
par_new.alpha_for_HBRM_cost = [0.01,0.1,1]; % respectively, corresponding to "stopping_time", "success probability", and "filtering_cost".

%=========== Roadmap Type and Construction
par_new.RoadMap = 'FIRM'; % This parameter can be HBRM or FIRM
par_new.No_history = 1;
par_new.No_plot = 1; % this is for plots in construction phase. The execution phase plots are different.

%=========== PRM parameters
par_new.PRM_parameters.neighboring_distance_threshold = 30; %* 1.25 * 1000;% * 0.3;
par_new.PRM_parameters.PRM_node_text = 1; % if this is one, the number of nodes will be written on the figure.
par_new.PRM_parameters.PRM_node_plot_properties =  {'RobotShape','triangle','robotSize',0.8};% {'RobotShape','triangle','robotSize',2};
par_new.PRM_parameters.draw_edges_flag = 1;

% =========== Orbit parameters
% par_new.PRM_parameters.orbit_text_size = 12;  % Default value for "OrbitTextSize" property.
% par_new.PRM_parameters.orbit_text_shift = 0.8; % for some reason MATLAB shifts the starting point of the text a little bit to the right. So, we return it back by this amount.
% par_new.PRM_parameters.orbit_text_color = 'b'; % Default value for "OrbitTextColor" property.
% par_new.PRM_parameters.orbit_robot_shape = 'triangle'; % The shape of robot (to draw trajectories and to show direction of edges and orbits)
% par_new.PRM_parameters.orbit_robot_size = 1; % Robot size on orbits (to draw trajectories and to show direction of edges and orbits)
par_new.PRM_parameters.node_to_orbit_trajectories_flag = 1; % Make it one if you want to see the node-to-orbit trajectories. Zero, otherwise.
% par_new.PRM_parameters.orbit_color = 'k'; % User-provided value for "orbit_color" property.
% par_new.PRM_parameters.orbit_width = 2; % User-provided value for "orbit_width" property.
% par_new.PRM_parameters.orbit_trajectory_flag = 0; % Make it one if you want to see the orbit trajectories. Zero, otherwise.
% par_new.PRM_parameters.edge_spec = '-b'; % edge line color and type
% par_new.PRM_parameters.edge_width = 2; % edge line width
par_new.PRM_parameters.num_nodes_on_orbits = 3; % number of nodes on each orbit
% par_new.PRM_parameters.orbit_length = 50; % the length of orbit (orbit's time period)
% par_new.PRM_parameters.orbit_radius = 4;

%===========  Dynamic Programming parameters
par_new.initial_values = 100;
par_new.initial_value_goal = 500;
par_new.failure_cost_to_go = 15;
par_new.selected_nodes_for_plotting_feedback_pi = [];%setdiff(1:22, [4,7,19,17,8,20,12,3,6,21]);
par_new.DP_convergence_threshold = 1e-2;

%===========  Replanning
par_new.replanning = 0;
par_new.goBack_to_nearest_node = 0; % this does not work correctly, yet.

%=========== FIRM Node Parameters
if strcmpi(par_new.motion_model_parameters.label,'Multi RandomWalk robots')
    error('these parameters should go into the class')
    n = par_new.state_parameters.num_robots;
    tmp_vector = repmat( [0.08 ; 0.08 ] , n , 1);
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
elseif strcmpi(par_new.motion_model_parameters.label,'Multi Omni-directional robots')
    error('these parameters should go into the class')
    n = par_new.state_parameters.num_robots;
    tmp_vector = repmat( [0.08 ; 0.08 ; 3 *pi/180 ] , n , 1);
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
elseif strcmpi(par_new.motion_model_parameters.label,'Revolute joint 8arm manipulator')
    error('these parameters should go into the class')
    tmp_vector = ones(par_new.state_parameters.stateDim , 1)*5*pi/180;
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
elseif strcmpi(par_new.motion_model_parameters.label,'Dynamical planar 8arm manipulator')
    error('these parameters should go into the class')
    tmp_vector = [ones(par_new.state_parameters.stateDim/2 , 1)*5*pi/180;ones(par_new.state_parameters.stateDim/2 , 1)*10*pi/180];
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
elseif strcmpi(par_new.motion_model_parameters.label,'FixedWing Aircraft')
    error('these parameters should go into the class')
    tmp_vector = repmat( [0.1 ; 0.1 ; 0.1; 0.1 ; 0.1 ; 0.1 ; 0.1] , 1 , 1);
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
elseif strcmpi(par_new.motion_model_parameters.label,'Quadrotor')
    error('these parameters should go into the class')
    tmp_vector = [1 ; 1 ; 1; 20*pi/180 ; 20*pi/180 ; 20*pi/180 ; inf ; inf ; inf ; inf ; inf ; inf];
    par_new.FIRM_node_parameters.mean_neighborhood_size = tmp_vector*mean_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian.
    par_new.FIRM_node_parameters.cov_neighborhood_size = tmp_vector*tmp_vector'*cov_neighb_magnifying_coeff ; % note that the last entry, ie theta's neighborhood, has to be in radian. % This is a matrix.
    % Hbliefe convergece-related parameters:
    GHb_conv_reg_thresh = tmp_vector*GHb_magnifyikng_coeff; % distance threshold for either Xg_mean or Xest_mean_mean; Xdist has to be a column vector
else
   
end


%=======================================================================================
%=======================================================================================
% End of Parameters section!
end

function [motion_model_parameters , state_parameters] = gather_state_and_motion_model_parameters(old_par, selected_motion_model)
% --- This function returns the parameters needed in the selected motion model.

if strcmpi(selected_motion_model,'Omni-directional three wheel robot')
    
elseif strcmpi(selected_motion_model,'Multi Omni-directional robots')
    error('these parameters should go into the class')
    n = 2;
    state_parameters.num_robots=n;
    state_parameters.stateDim = 3*n;
    state_parameters.sup_norm_weights_nonNormalized = repmat(1./[1 ; 1 ; inf] , n , 1); % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim=3*n;
    motion_model_parameters.robot_link_length = 0.2; %str2double(get(handles.edit_omni_link_length,'String'));
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.V_const_path_team=ones(1,n); % nominal linear velocity
    motion_model_parameters.omega_const_path_team=ones(1,n)*90*pi/180; % nominal angular velocity % note that this is the turning angle in one second. So, it will be multiplied by "dt" to return the turning angle in "dt".
    motion_model_parameters.eta_u_omni_team = zeros(3*n,1); % %str2num(get(handles.edit_eta_u_omni,'String'))'; %#ok<ST2NM> % note that eta_u in this case is a three by one vector, reprensing eta for velocity of each of omni-dir wheels.
    motion_model_parameters.sigma_b_u_omni_team = zeros(3*n,1); % % note that sigma_b_u in this case is a three by one vector, reprensing sigma_b (bias variance) for linear velocity and angular velocity.
    P_rootsqaure_Wg_diags_team = repmat( [0.2 ; 0.2 ; 4*pi/180]*2, n ,1 ); % this is just a vector
    motion_model_parameters.P_Wg_team = diag(P_rootsqaure_Wg_diags_team.^2);
elseif strcmpi(selected_motion_model,'Multi RandomWalk robots')
    error('these parameters should go into the class')
    n = 1;
    state_parameters.num_robots=n;
    state_parameters.stateDim = 2*n;
    state_parameters.sup_norm_weights_nonNormalized = repmat(1./[1 ; 1 ] , n , 1); % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim=2*n;
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.V_const_path_team=ones(2*n,1)*20; % nominal linear velocity
    P_rootsqaure_Wg_diags_team = repmat( [0.2 ; 0.2]*2, n ,1 ); % this is just a vector
    motion_model_parameters.P_Wg_team = diag(P_rootsqaure_Wg_diags_team.^2);    
elseif strcmpi(selected_motion_model,'Unicycle')
    error('these parameters should go into the class')
    state_parameters.stateDim = 3;
    state_parameters.sup_norm_weights_nonNormalized = 1./[1 ; 1 ; inf]; % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim=2;
    motion_model_parameters.base_length = 13; %str2double(get(handles.edit_unicycle_base_length,'String'));
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.V_const_path = 4; % nominal linear velocity
    motion_model_parameters.omega_const_path=25*pi/180; % nominal angular velocity
    motion_model_parameters.eta_u_unicycle = [0; 0];  % %str2num(get(handles.edit_eta_u_unicycle,'String'))'; %#ok<ST2NM> % note that eta_u in this case is a two by one vector, reprensing eta for linear velocity and angular velocity.
    motion_model_parameters.sigma_b_u_unicycle = [0; 0]; % % note that sigma_b_u in this case is a two by one vector, reprensing sigma_b (bias variance) for linear velocity and angular velocity.
    P_rootsqaure_Wg_diags=[0.2 ; 0.2 ; 4*pi/180];
    motion_model_parameters.P_Wg=diag(P_rootsqaure_Wg_diags.^2);
elseif strcmpi(selected_motion_model,'Revolute joint 8arm manipulator')
    error('these parameters should go into the class')
    n = 8;
    state_parameters.num_revolute_joints = n;
    state_parameters.stateDim = n;
    state_parameters.sup_norm_weights_nonNormalized = ones(n , 1); % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim=n;
elseif strcmpi(selected_motion_model,'Dynamical planar 8arm manipulator')
    error('these parameters should go into the class')
    n = 16;
    state_parameters.num_revolute_joints = n/2;
    state_parameters.stateDim = n;
    state_parameters.sup_norm_weights_nonNormalized = ones(n , 1); % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim = n/2;
elseif strcmpi(selected_motion_model,'FixedWing Aircraft')
    error('these parameters should go into the class')
    state_parameters.stateDim = 7;
    state_parameters.sup_norm_weights_nonNormalized = ones(state_parameters.stateDim , 1); 
    disp('state norm for aircraft model needs to be fixed')
    motion_model_parameters.controlDim = 4;
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.eta_u_aircraft = [0.005;0.005;0.005;0.005];%[0.01 ; deg2rad(0.025) ; deg2rad(0.025) ; deg2rad(0.025)];  
    motion_model_parameters.sigma_b_u_aircraft = [0.02; deg2rad(0.25);deg2rad(0.25); deg2rad(0.25)];%[0.01 ; deg2rad(0.2); deg2rad(0.2); deg2rad(0.2)];  
    P_rootsqaure_Wg_diags = [0.02 ; 0.02 ; 0.02 ; 0.01 ; 0.01 ; 0.01 ; 0.01];
    motion_model_parameters.P_Wg = diag(P_rootsqaure_Wg_diags.^2);
elseif strcmpi(selected_motion_model,'Kuka YouBot Base')
    error('these parameters should go into the class')
    state_parameters.stateDim = 3;
    state_parameters.sup_norm_weights_nonNormalized = 1./[1 ; 1 ; inf]; % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim = 4;
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.eta_u_KukaBase = [0; 0; 0; 0]; 
    motion_model_parameters.sigma_b_u_KukaBase = [0; 0; 0; 0];  
    P_rootsqaure_Wg_diags=[0.2 ; 0.2 ; 4*pi/180]*2;
    motion_model_parameters.P_Wg=diag(P_rootsqaure_Wg_diags.^2);
    motion_model_parameters.distBetweenFrontWheels = 0.158*2; % from YouBot datasheet
    motion_model_parameters.distBetweenFrontAndBackWheels = 0.228*2; % from YouBot datasheet
elseif strcmpi(selected_motion_model,'Quadrotor')
    error('these parameters should go into the class')
    state_parameters.stateDim = 12;
    state_parameters.sup_norm_weights_nonNormalized = 1./[1 ; 1 ; 1; inf(9,1)]; % You can think of the right-most vector (in the denominator) as the ractangular neighborhood used in finding neighbor nodes in constructing PRM graph. Note that this must be a column vector.
    motion_model_parameters.controlDim = 4;
    motion_model_parameters.dt = 0.1;
    motion_model_parameters.eta_u_quadrotor = [0; 0; 0; 0];  % str2num(get(handles.eta_u_quadrotor,'String'))'; %#ok<ST2NM> % note that eta_u in this case is a four by one vector, reprensing the dependence of control noise on the magnitude of the control vector.
    motion_model_parameters.sigma_b_u_quadrotor = [0; 0; 0; 0];  % note that sigma_b_u in this case is a four by one vector, reprensing sigma_b (bias variance) for the control-independent part of the control noise.
    P_rootsqaure_Wg_diags=[0.2 ; 0.2 ; 0.2 ; 0.001 ; 0.001 ; 0.001; 4*pi/180 ; 4*pi/180 ; 4*pi/180 ; 0.001 ; 0.001 ; 0.001];
    motion_model_parameters.P_Wg=diag(P_rootsqaure_Wg_diags.^2);
else
    motion_model_parameters = [];  % Here, we load the "old motion model parameters", so that the old information that we do not change, remains unaffected.
    state_parameters = [];
end
end