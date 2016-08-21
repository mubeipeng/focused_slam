classdef Embedded_Simulator < SimulatorInterface
    properties
        sceneHierarchy %% an structure containing Scene Hierarchy (objects in the scene like floor , walls) and their children and properties
        robot
        obstacle
        landmarkMap
        simulatorName = 'Embedded';
        videoObj
        par
    end
    
    methods
        % constructor
        function obj = Embedded_Simulator()
            global par;
            % in constructor we retrive the paraemters of the planning
            % problem entered by the user.
            obj.par = par.simulator_parameters;
            monitor_pos = get(0,'MonitorPositions'); % first line is for the first monitor and second line is for the second monitor.
            if prod(monitor_pos(1,:))>0 % Checks if all the elements of the monitor screen coordinates are positive. If not, it means that first monitor should not be used.
                main_monitor_pos = monitor_pos(1,:);
            else
                main_monitor_pos = monitor_pos(end,:);
            end
            x_offset = 35;y_offset = 35;
            ratio = 0.8;
            obj.par.figure_position = [main_monitor_pos(1)+x_offset  , main_monitor_pos(1)+y_offset  ,  main_monitor_pos(4)*ratio  ,  main_monitor_pos(4)*ratio]; % if this variable is empty, figure size will be the default value.
            obj.par.video = 0;
            obj.par.video_quality = 100;
            obj.par.interactive_disturbance_allowed = 0 ;
            obj.par.draw_at_every_n_steps = 2;
            obj.par.FrameRate = 5;
            obj.par.env_limits = [-5 105 -10 105]; %[-3.75 , 100 , -23.75 , 80]; %[-3 155 -3 155]; %[-10 10 -10 10];%[-6 104 -28 85];%[-5 265 -5 225];%[-6 104 -28 85];
            obj.par.env_z_limits = [5 20];
            obj.par.top_obstacle_height_3D = 25;
            obj.par.bottom_obstacle_height_3D = 0;
            obj.par.env_background_image_address = 'none'; %'C:\Ali\Academics\PhD_Paper_tryings\Needle_steering\Needle_pics_web\liver.png';%'none'; %'C:\Users\Ali\Desktop\Needle_pics_web\liver-panel5.png';  % This field has to be the address of some image or has to be 'none'
            obj.par.Lighting_and_3D_plots = 0;
            obj.par.imageResizeRatio = 0.25;
            obj.par.viewAngle = [0  90]; %[30,40];
            obj.par.initialZoomRatio = 1.2;%2.5;
            obj.par.verboseFlag = 1; % (0: suppresses the inermediate code messages intended for debugging purposes | 1: simulator will display messages  )
        end
        % initialize : initializes the simulator
        function obj = initialize(obj, system_labels)
            global par;
            old_prop = obj.set_figure(); %#ok<NASGU>
            
            if par.observation_model_parameters.interactive_OM == 0
                obj.landmarkMap = feval([system_labels.om,'.getMap'],obj);
                OM = feval(system_labels.om,obj.landmarkMap);
                OM.plot_handle = OM.draw(obj);
            end
            if obj.par.intractive_obst == 0
                obstacleMap = obstacles_class.get_obstacles(obj);
                obj.obstacle = obstacles_class(obstacleMap); % The object "Obstacles" is never used. This line only cause the "Constant" properties of the "obstacles_class" class to be initialized.
            end
            if obj.par.intractive_obst == 1
                obstacleMap = obstacles_class.get_obstacles(obj);
                obj.obstacle = obstacles_class(obstacleMap); % The object "Obstacles" is never used. This line only cause the "Constant" properties of the "obstacles_class" class to be initialized.
            end
            if par.observation_model_parameters.interactive_OM == 1
                % OM = ObservationModel_class; % The object OM is only created for "Constant" properties of the "ObservationModel_class" class to be initialized.
                obj.landmarkMap = feval([system_labels.om,'.getMap'],obj);
                OM = feval(system_labels.om,obj.landmarkMap);
                OM.plot_handle = OM.draw(obj);
            end
            
            % video making
            if obj.par.video == 1;
                [file,path] = uiputfile('OnlinePhaseVideo.avi','Save the runtime video as');
                vidObj = VideoWriter(fullfile(path,file));
                vidObj.Quality = obj.par.video_quality;
                vidObj.FrameRate = obj.par.FrameRate;
                open(vidObj);
                obj.videoObj = vidObj;
            end
            %obj = Environment_construction(obj); % Construct the environment (obstacles, landmarks, PRM)
            if ~strcmpi(obj.par.env_background_image_address,'none') % check to see if the environment has any background picuture or not
                background = imread(obj.par.env_background_image_address);
                smaller_background=imresize(background,obj.par.imageResizeRatio);
                smaller_background = flipdim(smaller_background,1);
                warp(smaller_background); axis on; set(gca,'Ydir','normal');view(0,90)
            end
            if obj.par.Lighting_and_3D_plots == 1
                view(obj.par.viewAngle);
                camlight('right')
                camzoom(obj.par.initialZoomRatio)
            end
        end
        
        function obj = addRobot(obj,robot_inp)
            obj.robot = robot_inp;
        end
        
        % SetRobot : change robot parameters
        function obj = setRobot(obj,robot_pose)
            if ~isfield(obj.robot.ss,'plot_handle') || isempty(obj.robot.ss.plot_handle) % if this is empty, it shows that the robot field is not initialized yet or we have deleted
                % its handle that is we want to dreaw ir wirh a new handle
                if ~isa(robot_pose, obj.robot.ss.label), robot_pose = feval(obj.robot.ss.label, robot_pose); end
                
                obj.robot.ss = robot_pose;
            else
                % otherwose just update the value
                if ~isa(robot_pose, obj.robot.ss.label), newVal = feval(obj.robot.ss.label, robot_pose); end
                
                obj.robot.ss.val = newVal.val;
            end
        end
        % GetRobot : get robot parameters
        function robot = getRobot(obj)
            robot = obj.robot;
        end
        % Refresh :
        function obj = refresh(obj)
            obj.robot.ss = obj.robot.ss.delete_plot();
            obj.robot.ss = obj.robot.ss.draw('triacolor','g','color','g');
%             obj.robot.belief = obj.robot.belief.delete_plot();
%             obj.robot.belief = obj.robot.belief.draw();
            
            %%% below lines should be deleted soon
            obj.robot.belief.est_mean.draw('triacolor', 'r')
            obj.robot.belief = obj.robot.belief.draw_CovOnNominal(obj.robot.ss,'magnify',2);
%             global om_computational;
%             om_computational = om_computational.draw_visible_landmarks(obj.robot.belief.est_mean.val);
            drawnow;
            if obj.par.video == 1
                obj = obj.recordVideo();
            end    
        end
        function obj = recordVideo(obj)
            %if user_data_class.par.sim.video == 1
                currFrame = getframe(gcf);
                writeVideo(obj.videoObj ,currFrame);
            %end
        end
        function b = getBelief(obj)
            b = obj.belief;
        end
        function obj = setBelief(obj,b)
            if ~isfield(obj.robot.belief,'ellipse_handle') || ~isempty(obj.robot.belief.ellipse_handle) || ~isempty(obj.robot.belief.est_mean.plot_handle)
                % if any of the belief object's graphics handles are
                % non-empty, we just
                obj.robot.belief.est_cov = b.est_cov;
                obj.robot.belief.est_mean.val = b.est_mean.val;
            else
                obj.robot.belief = b;
            end
        end
        % stopRun (not sure about this one)
        function obj = simStop(obj)
            disp('Simulation Stopped')
        end
        % evolve : evolve robot
        function obj = evolve(obj,u,varargin)
            if nargin==3
                noiseMode = varargin{1};
            else
                noiseMode = 1; % by default we add noise
            end
            if noiseMode
                w = obj.robot.mm.generate_process_noise(obj.robot.ss.val,u);
            else
                w = obj.robot.mm.zeroNoise;
            end
            obj.robot.ss.val = obj.robot.mm.f_discrete(obj.robot.ss.val,u,w);
        end
        
        function z = getObservation(obj, noiseMode)
            % generating observation noise
            if noiseMode
                v = obj.robot.om.generate_observation_noise(obj.robot.ss.val);
            else
                v = obj.robot.om.zeroNoise;
            end
            % constructing ground truth observation
            z = obj.robot.om.h_func(obj.robot.ss.val,v);
        end
        function isCollided = checkCollision(obj)
            isCollided = obj.robot.ss.is_constraint_violated(obj);
        end
        
    end
    
    methods (Access = private)
        function old_prop = set_figure(obj) % This function sets the figure (size and other properties) to values that are needed for landmark selection or drawing.
            figure(gcf);
            if ~strcmpi(obj.par.env_background_image_address,'none') % check to see if the environment has any background picuture or not
                background = imread(obj.par.env_background_image_address);
                smaller_background=imresize(background,obj.par.imageResizeRatio);
                smaller_background = flipdim(smaller_background,1);
                imshow(smaller_background); axis on; set(gca,'Ydir','normal');view(0,90)
            end
            old_prop{1}=get(gca,'NextPlot');hold on; % save the old "NextPlot" property and set it to "hold on" % Note that this procedure cannot be moved into the "set_figure" function.
            old_prop{2}=get(gca,'XGrid'); % save the old "XGrid" property.
            old_prop{3}=get(gca,'YGrid'); % save the old "YGrid" property.
            grid on; % set the XGrid and YGrid to "on".
            axis off;
            if ~isempty(obj.par.figure_position)
                set(gcf,'Position',obj.par.figure_position)
            end
            axis(obj.par.env_limits);
            axis equal;
%             set(gca,'DataAspectRatio',[1 1 1]); % makes the scaling of different axes the same. So, a circle is shown as a circle not ellipse.
            %             gray_box_position = get(gca, 'OuterPosition');
            %             set(gca, 'Position', gray_box_position);
        end
    end
    
end
