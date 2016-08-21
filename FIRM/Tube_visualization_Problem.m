classdef Tube_visualization_Problem
    %PLANNING_PROBLEM is a base class, from which one can instantiate a planning problem with a user inputed environment (obstacles and information sources)
    
    properties
        robot;
        sim;
        PRM;
        FIRM_graph;
        par;
    end
    
    methods
        function obj = Tube_visualization_Problem(sim_inp, robot_inp)
            obj.par = user_data_class.par.planning_problem_parameters;
            obj.sim = sim_inp;
            obj.robot = robot_inp;
        end
        function obj = solve(obj)
            wayPoints = getWayPoints();
            
            est_mean = feval(class(obj.robot.ss), wayPoints{1}');
            est_cov = eye(length(est_mean.val))*2.5;
            
            bel = feval(class(obj.robot.belief), est_mean, est_cov);
            
            % set the robot and belief in the simulator
            obj.sim = obj.sim.setRobot(est_mean);
            obj.sim = obj.sim.setBelief(bel);
            
            for i = 2:5%length(wayPoints)
                %%% setting the heading angles at way points
                nominal_trajectory = obj.sim.robot.mm.generate_VALID_open_loop_point2point_traj(wayPoints{i-1},wayPoints{i},obj.sim);
                
                for k = 1:length(nominal_trajectory.u)
                
                    S_LQG = SLQG_class(nominal_trajectory.x(:,k), obj.robot);
                    Pest = S_LQG.Stationary_Gaussian_Hb.Pest;
                    
%                     FT_LQG = Finite_time_LQG_class(obj.robot, nominal_trajectory,'EKF');
                
%                 noiseFlag = 1;
                
                    
                    [bel,~,obj.sim,~] = FT_LQG.executeOneStep(bel,k,obj.sim,noiseFlag);
                    obj.sim = obj.sim.setBelief(bel);
                    obj.sim = obj.sim.refresh();
                    
                    collision_flag = obj.sim.checkCollision();
                    
                    if collision_flag
                        return
                    end
                    
                end
                
            end
            
            %Full_data.logged_data = logged_data;
            
            % save('C:\Users\Ali\Desktop\data_BP', 'Full_data')
            
        end
    end
end