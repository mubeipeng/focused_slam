classdef Navigation_Problem
    %PLANNING_PROBLEM is a base class, from which one can instantiate a planning problem with a user inputed environment (obstacles and information sources)
    
    properties
        robot;
        sim;
        PRM;
        FIRM_graph;
        par;
    end
    
    methods
        function obj = Navigation_Problem(sim_inp, robot_inp)
            global par;
            obj.par = par.planning_problem_parameters;
            obj.sim = sim_inp;
            obj.robot = robot_inp;
        end
        function [logged_data]= solve(obj)
            wayPoints = getWayPoints();
            
            est_mean = feval(class(obj.robot.ss), wayPoints{1}');
            est_cov = eye(length(est_mean.val))*2.5;
            
            bel = feval(class(obj.robot.belief), est_mean, est_cov);
            
            % set the robot and belief in the simulator
            obj.sim = obj.sim.setRobot(est_mean);
            obj.sim = obj.sim.setBelief(bel);
            
            robot_ss = zeros(3,2000); robot_cov=zeros(1,2000);n=0;
            for i = 2:11%length(wayPoints)
                %%% setting the heading angles at way points
                nominal_trajectory = obj.sim.robot.mm.generate_VALID_open_loop_point2point_traj(wayPoints{i-1},wayPoints{i},obj.sim);
                
                FT_LQG = Finite_time_LQG_class(obj.robot, nominal_trajectory,'EKF');
                
                noiseFlag = 1;
                for k = 1:length(nominal_trajectory.u)
                    
                    [bel, obj.sim,~] = FT_LQG.executeOneStep(bel,k,obj.sim,noiseFlag);
                    
                    n=n+1;
                    robot_ss(:,n) = bel.est_mean.val;robot_cov(1,n)=bel.est_cov(1,1);
                    
                    obj.sim = obj.sim.setBelief(bel);
                    if mod(k,obj.sim.par.draw_at_every_n_steps) == 0
                        obj.sim = obj.sim.refresh(); 
                    end
                    
                    collision_flag = obj.sim.checkCollision();
                    
                    if collision_flag
                        logged_data.x = robot_ss(:,1:n);
                        logged_data.cov = robot_cov(:,1:n);
                        return
                    end
                    
                end
                
            end
            
            logged_data.x = robot_ss(:,1:n);
            logged_data.cov = robot_cov(:,1:n);
            close(obj.sim.videoObj);
            %Full_data.logged_data = logged_data;
            
            % save('C:\Users\Ali\Desktop\data_BP', 'Full_data')
            
        end
    end
end